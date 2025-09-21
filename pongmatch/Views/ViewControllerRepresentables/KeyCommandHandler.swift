import SwiftUI

struct KeyCommandHandler: UIViewControllerRepresentable {
    let onKeyPress: (UIKeyCommand) -> Void
    
    func makeUIViewController(context: Context) -> KeyCommandHostingController {
        let controller = KeyCommandHostingController()
        controller.onKeyPress = onKeyPress
        return controller
    }
    
    func updateUIViewController(_ uiViewController: KeyCommandHostingController, context: Context) {}
    
    class KeyCommandHostingController: UIViewController {
        var onKeyPress: ((UIKeyCommand) -> Void)?
        
        override var keyCommands: [UIKeyCommand]? {
            [
                UIKeyCommand(input: " ", modifierFlags: [], action: #selector(handleKey(_:))),
                UIKeyCommand(input: "a", modifierFlags: [], action: #selector(handleKey(_:))),
                UIKeyCommand(input: "b", modifierFlags: [], action: #selector(handleKey(_:))),
                
                //Gamepad
                UIKeyCommand(input: "h", modifierFlags: [], action: #selector(handleKey(_:))), //player1
                UIKeyCommand(input: "i", modifierFlags: [], action: #selector(handleKey(_:))), //player2
                UIKeyCommand(input: "y", modifierFlags: [], action: #selector(handleKey(_:))), //undo
                UIKeyCommand(input: "j", modifierFlags: [], action: #selector(handleKey(_:))), //redo
            ]
        }
        
        @objc func handleKey(_ sender: UIKeyCommand) {
            onKeyPress?(sender)
        }
        
        override var canBecomeFirstResponder: Bool { true }
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            becomeFirstResponder()
        }
    }
}
