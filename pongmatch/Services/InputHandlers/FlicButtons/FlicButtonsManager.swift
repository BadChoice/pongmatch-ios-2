import Foundation
import flic2lib
import SwiftUI
import Combine

class FlicButtonsManager : NSObject, FLICButtonDelegate, FLICManagerDelegate, ObservableObject {

    static var shared = FlicButtonsManager.init()
    
    @Published var buttons:[FLICButton] = []
    @Published var isScanning:Bool = false
    
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
            switch event {
            case .discovered:           print("discovered")
            case .connected:            print("connected")
            case .verified:             print("Verified")
            case .verificationFailed:   print("verify failed")
            @unknown default:           print("unknown event")
            }
        } completion: { [unowned self] button, error in
            isScanning = false
            if let error {
                print("[FLIC] \(error.localizedDescription))")
            } else if let button {
                print("[FLIC] Successfully verified: \(button.name ?? "Unknown"), \(button.bluetoothAddress), \(button.serialNumber)")
                button.triggerMode = .clickAndDoubleClickAndHold
                //buttons.append(button)
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
    
    func rename(_ button:FLICButton, to newName:String) async {
        isScanning = true
        button.nickname = newName
        isScanning = false
    }
    
    func manager(_ manager: FLICManager, didUpdate state: FLICManagerState) {
        print("[FLIC] Manager did update state: \(state.rawValue)")
        refreshButtons()
    }
    
    
    func managerDidRestoreState(_ manager: FLICManager) {
        print("[FLIC] Manager did restore state")
        refreshButtons()
    }
    
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
    
    // MARK: - FLICButtonDelegate - Button Events
    func button(_ button: FLICButton, didReceiveButtonUp queued: Bool, age: Int) {
        print("[Flic] \(button.name ?? "Unkwnown") was clicked up with age \(age)")
    }
    
    func button(_ button: FLICButton, didReceiveButtonDown queued: Bool, age: Int) {
        print("[FLIC] \(button.name ?? "Unkwnown") was clicked down with age \(age)")
    }
    
    func button(_ button: FLICButton, didReceiveButtonDoubleClick queued: Bool, age: Int) {
        print("[FLIC] \(button.name ?? "Unkwnown") was doubleclicked down with age \(age)")
    }
    
    func button(_ button: FLICButton, didReceiveButtonHold queued: Bool, age: Int) {
        print("[FLIC] \(button.name ?? "Unkwnown") was hold down with age \(age)")
    }
    
    func button(_ button: FLICButton, didReceiveButtonClick queued: Bool, age: Int) {
        print("[FLIC] \(button.name ?? "Unkwnown") was clicked down with age \(age)")
    }
    
    private func refreshButtons(){
        buttons = FLICManager.shared()?.buttons() ?? []
        
        /*if (buttons.contains {
            $0.identifier == button.identifier
        }) {
            return
        }
        
        print("[FLIC] Adding button to known buttons: \(button.name ?? "Unknown")")
        buttons.append(button)*/
    }
}

