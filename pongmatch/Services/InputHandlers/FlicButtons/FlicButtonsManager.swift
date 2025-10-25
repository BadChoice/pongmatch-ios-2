import Foundation
import flic2lib
import SwiftUI
import Combine

enum FlicButtonClickType {
    case buttonUp
    case buttonDown
    case doubleClick
    case hold
    case click
}
    
@MainActor
class FlicButtonsManager : NSObject, FLICButtonDelegate, FLICManagerDelegate, ObservableObject {

    static var shared = FlicButtonsManager.init()
    
    var clickDelegate:((_ identifier:String, _ type:FlicButtonClickType)->Void)?
    
    @Published var buttons:[FLICButton] = []
    @Published var isScanning:Bool = false

    // Extracted pressed highlight logic into its own observable object
    @Published var highlights = PressedButtonHighlights()
    
    // Keep Combine subscriptions alive
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        // Forward nested object changes so views observing the manager refresh
        highlights.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    @discardableResult
    func setup() -> Self {
        print("[FLIC] Setting up FLIC Manager...")
        FLICManager.configure(with: self, buttonDelegate: self, background: true)
        return self
    }
    
    func scan() {
        print("[FLIC] Scanning for buttons...")
        isScanning = true
        FLICManager.shared()?.scanForButtons { event in
            print("[FLIC] \(event)")
        } completion: { [unowned self] button, error in
            isScanning = false
            if let error {
                print("[FLIC] \(error.localizedDescription))")
            } else if let button {
                print("[FLIC] Successfully verified: \(button.name ?? "Unknown"), \(button.bluetoothAddress), \(button.serialNumber)")
                button.triggerMode = .clickAndDoubleClickAndHold
                refreshButtons()
            }
       }
    }        
    
    func forget(_ button:FLICButton) async {
        do {
            try await FLICManager.shared()?.forgetButton(button)
            buttons = buttons.filter { $0.identifier != button.identifier }
        } catch {
          print("[FLIC] Error forgetting button: \(error.localizedDescription)")
        }
    }
    
    func clickDelegate( delegate:@escaping(_ identifier:String, _ type:FlicButtonClickType)->Void ) {
        setup()
        clickDelegate = delegate
    }
        
    func buttonForIdentifier(_ identifier:String?) -> FLICButton? {
        guard let identifier else { return nil }
        return buttons.first { $0.identifier.uuidString == identifier }
    }
    
    func manager(_ manager: FLICManager, didUpdate state: FLICManagerState) {
        print("[FLIC] Manager did update state: \(state.rawValue)")
        refreshButtons()
    }
    
    func managerDidRestoreState(_ manager: FLICManager) {
        print("[FLIC] Manager did restore state")
        refreshButtons()
    }

    private func refreshButtons(){
        Task {
            await MainActor.run {
                buttons = FLICManager.shared()?.buttons() ?? []
            }
        }
    }
    
    //---------------------------------------------------------------
    // MARK: - FLICButtonDelegate - Button Connection Events
    //---------------------------------------------------------------
    func buttonIsReady(_ button: FLICButton) {
        print("[FLIC] Button is ready: \(button.name ?? "Unknown")")
        refreshButtons()
    }
    
    func buttonDidConnect(_ button: FLICButton) {
        print("[FLIC] Button did connect: \(button.name ?? "Unknown")")
        refreshButtons()
    }
    
    func button(_ button: FLICButton, didFailToConnectWithError error: (any Error)?) {
        print("[FLIC] Button did fail to connect: \(button.name ?? "Unknown"), error: \(error?.localizedDescription ?? "none")")
    }
    
    func button(_ button: FLICButton, didDisconnectWithError error: (any Error)?) {
        print("[FLIC] Button did disconnect: \(button.name ?? "Unknown"), error: \(error?.localizedDescription ?? "none")")
    }
    
    func buttonDidDisconnect(_ button: FLICButton, withError error: (any Error)?) {
        print("[FLIC] Button did disconnect: \(button.name ?? "Unknown"), error: \(error?.localizedDescription ?? "none")")
    }
    
    func button(_ button: FLICButton, didUpdateNickname nickname: String) {
        print("[FLIC] Button did update nickname: \(button.name ?? "Unknown") to \(nickname)")
    }
    
    //---------------------------------------------------------------
    // MARK: - FLICButtonDelegate - Button Events
    //---------------------------------------------------------------
    func button(_ button: FLICButton, didReceiveButtonUp queued: Bool, age: Int) {
        print("[Flic] \(button.name ?? "Unkwnown") was clicked up with age \(age)")
        clickDelegate?(button.identifier.uuidString, .buttonUp)
    }
    
    func button(_ button: FLICButton, didReceiveButtonDown queued: Bool, age: Int) {
        print("[FLIC] \(button.name ?? "Unkwnown") was clicked down with age \(age)")
        highlights.trigger(id: button.identifier) // start the 1s fade
        clickDelegate?(button.identifier.uuidString, .buttonDown)
    }
    
    func button(_ button: FLICButton, didReceiveButtonDoubleClick queued: Bool, age: Int) {
        print("[FLIC] \(button.name ?? "Unkwnown") was doubleclicked down with age \(age)")
        clickDelegate?(button.identifier.uuidString, .doubleClick)
    }
    
    func button(_ button: FLICButton, didReceiveButtonHold queued: Bool, age: Int) {
        print("[FLIC] \(button.name ?? "Unkwnown") was hold down with age \(age)")
        clickDelegate?(button.identifier.uuidString, .hold)
    }
    
    func button(_ button: FLICButton, didReceiveButtonClick queued: Bool, age: Int) {
        print("[FLIC] \(button.name ?? "Unkwnown") was clicked down with age \(age)")
        clickDelegate?(button.identifier.uuidString, .click)
    }
}

extension FLICButton {
    var displayName : String {
        if let nickname, !nickname.isEmpty {
            return nickname
        }
        if let name, !name.isEmpty {
            return name
        }
        return "Unknown"
    }
}
