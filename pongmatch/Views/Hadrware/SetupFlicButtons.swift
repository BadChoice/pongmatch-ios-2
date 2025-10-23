import SwiftUI
import flic2lib

struct SetupFlicButtons: View {
    
    @StateObject var flicManager = FlicButtonsManager.shared
    @State var assignment = FlicAssignment.get()
    
    var body: some View {
        List {
            sectionHeader
            assignmentSection
            pairingSection
            knownButtonsSection
        }
        .navigationTitle("Flic Buttons Setup")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh")
            }
        }
        .onAppear {
            flicManager.setup()
        }
    }
    
    // MARK: Sections
    private var sectionHeader: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Assign your Flic buttons to each player to control the scoreboard hands‑free.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Press “Pair new button” to add a Flic button, then assign it to Player 1 or Player 2.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
    
    private var assignmentSection: some View {
        Section("Assignments") {
            HStack {
                Label("Player 1", systemImage: "1.circle")
                Spacer()
                if let buttonId = assignment.player1 {
                    Text(buttonId).foregroundStyle(.secondary)
                }else {
                    Text("Not assigned").foregroundStyle(.secondary)
                }
            }
            HStack {
                Label("Player 2", systemImage: "2.circle")
                Spacer()
                if let buttonId = assignment.player2  {
                    Text(buttonId).foregroundStyle(.secondary)
                } else {
                    Text("Not assigned").foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var pairingSection: some View {
        Section("Pairing") {
            Button {
                flicManager.scan()
            } label: {
                HStack {
                    Text("Pair new button")
                    if flicManager.isScanning {
                        Spacer()
                        ProgressView()
                    }
                }
            }
        }
    }
    
    private var knownButtonsSection: some View {
        Section("Known buttons") {
            if flicManager.buttons.isEmpty {
                Text("No paired buttons found").foregroundStyle(.secondary)
            } else {
                ForEach(flicManager.buttons, id:\.identifier) { button in
                    knownButtonRow(button)
                }
            }
        }
    }
    
    private func knownButtonRow(_ button: FLICButton) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(button.name ?? "Flic Button")
                    .font(.subheadline.weight(.semibold))
            }
            Spacer()
            Text("\(button.batteryVoltage)")
            Menu {
                // Assign to Player 1
                Button {
                    assignment.player1 = button.identifier.uuidString
                    assignment.save()
                } label: {
                    Text("Assign to Player 1")
                }
                // Assign to Player 2
                Button {
                    assignment.player2 = button.identifier.uuidString
                    assignment.save()
                } label: {
                    Text("Assign to Player 2")
                }
                
                Button {
                    Task {
                        await flicManager.forget(button)
                    }
                } label: {
                    Text("Forget")
                }
                
                Button {
                    Task {
                        await flicManager.rename(button, to:"New name")
                    }
                } label: {
                    Text("Rename")
                }
                
                
                Divider()
            } label: {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
                    .padding(.vertical, 4)
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        SetupFlicButtons()
    }
}
