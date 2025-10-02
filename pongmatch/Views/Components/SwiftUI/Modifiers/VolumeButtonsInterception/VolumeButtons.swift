import SwiftUI
import MediaPlayer

class VolumeButtonObserver {
    private var observation: NSKeyValueObservation?
    private let audioSession = AVAudioSession.sharedInstance()
    
    var onVolumeUp: (() -> Void)?
    var onVolumeDown: (() -> Void)?
    
    private var lastVolume: Float = 0.5
    private let volumeView: MPVolumeView!

    private var isSettingVolume:Bool = false
    
    init() {
        try? audioSession.setActive(true)
        //lastVolume = audioSession.outputVolume
        
        // Create a hidden MPVolumeView so iOS lets us intercept
        volumeView = MPVolumeView(frame: .zero)
        volumeView.isHidden = true
        UIApplication.shared.windows.first?.addSubview(volumeView)
        
        setVolume(0.5)

        
        observation = audioSession.observe(\.outputVolume, options: [.new]) { [weak self] _, change in
            guard let self, !isSettingVolume, let newVolume = change.newValue else { return }
            print("New volume: \(newVolume)")
            if newVolume > self.lastVolume {
                self.onVolumeUp?()
            } else if newVolume < self.lastVolume {
                self.onVolumeDown?()
            }
            self.resetVolume()
            //self.lastVolume = newVolume
        }
    }
    
    private func resetVolume() {
        // Reset volume back to lastVolume (0.5)
        setVolume(0.5)
    }
    
    private func setVolume(_ value: Float) {
        isSettingVolume = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            for subview in self.volumeView.subviews {
                if let slider = subview as? UISlider {
                    slider.value = value
                }
            }
            // Reset flag after a short delay to ensure the system processes the change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.isSettingVolume = false
            }
        }
    }
    
    deinit {
        observation?.invalidate()
        volumeView.removeFromSuperview()
    }
}

struct VolumeButtonHandler: ViewModifier {
    let onUp: () -> Void
    let onDown: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                VolumeHandlerView(onUp: onUp, onDown: onDown)
            )
    }
    
    private struct VolumeHandlerView: UIViewControllerRepresentable {
        let onUp: () -> Void
        let onDown: () -> Void
        
        func makeUIViewController(context: Context) -> UIViewController {
            let vc = UIViewController()
            let observer = VolumeButtonObserver()
            observer.onVolumeUp = onUp
            observer.onVolumeDown = onDown
            context.coordinator.observer = observer
            return vc
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator { Coordinator() }
        class Coordinator { var observer: VolumeButtonObserver? }
    }
}

extension View {
    func onVolumeButtons(up: @escaping () -> Void, down: @escaping () -> Void) -> some View {
        self.modifier(VolumeButtonHandler(onUp: up, onDown: down))
    }
}
