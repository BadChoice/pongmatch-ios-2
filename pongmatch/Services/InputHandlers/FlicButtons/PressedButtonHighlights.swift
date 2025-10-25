import Foundation
import SwiftUI
import Combine

@MainActor
final class PressedButtonHighlights: ObservableObject {

    // 1.0 -> 0.0 transient highlight intensity per button ID
    @Published private(set) var intensities: [UUID: Double] = [:]

    private var decayTasks: [UUID: Task<Void, Never>] = [:]

    func trigger(id: UUID, duration: TimeInterval = 1.0, steps: Int = 20) {
        // Set to full intensity
        intensities[id] = 1.0

        // Cancel any existing decay for this id
        decayTasks[id]?.cancel()

        // Start decay
        let task = Task { [weak self] in
            guard let self else { return }
            let clampedSteps = max(1, steps)
            let stepDuration = duration / Double(clampedSteps)

            for i in 1...clampedSteps {
                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                if Task.isCancelled { return }
                let remaining = max(0, 1.0 - (Double(i) / Double(clampedSteps)))
                await MainActor.run {
                    self.intensities[id] = remaining
                }
            }

            await MainActor.run {
                self.intensities.removeValue(forKey: id)
                self.decayTasks.removeValue(forKey: id)
            }
        }

        decayTasks[id] = task
    }

    func intensity(for id: UUID) -> Double {
        intensities[id] ?? 0
    }

    func intensity(for identifierString: String?) -> Double {
        guard let s = identifierString, let id = UUID(uuidString: s) else { return 0 }
        return intensities[id] ?? 0
    }

    func cancel(id: UUID) {
        decayTasks[id]?.cancel()
        decayTasks.removeValue(forKey: id)
        intensities.removeValue(forKey: id)
    }

    func cancelAll() {
        decayTasks.values.forEach { $0.cancel() }
        decayTasks.removeAll()
        intensities.removeAll()
    }
}

