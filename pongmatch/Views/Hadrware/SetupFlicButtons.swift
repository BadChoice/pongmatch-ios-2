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
        /*.navigationTitle("Flic Buttons Setup")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh")
            }
        }*/
        .onAppear {
            flicManager.setup()
        }
        .onDisappear{
            assignment.save()
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
            
            Picker("Assignment Mode", selection: $assignment.mode) {
                Text("Court").tag(FlicAssignmentMode.courtSide)
                Text("Player").tag(FlicAssignmentMode.player)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            HStack {
                Label(assignment.display(for: .player1), systemImage: assignment.icon(for: .player1))
                Spacer()
                if let button = flicManager.buttonForIdentifier(assignment.player1) {
                    Text(button.displayName).foregroundStyle(.secondary)
                } else {
                    Text("Not assigned").foregroundStyle(.secondary)
                }
            }
            HStack {
                Label(assignment.display(for: .player2), systemImage: assignment.icon(for: .player2))
                Spacer()
                if let button = flicManager.buttonForIdentifier(assignment.player2)  {
                    Text(button.displayName).foregroundStyle(.secondary)
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
            Image(systemName: "circle.fill").foregroundStyle(
                button.isReady ? .green : .red)
                .font(.caption)
            
            Image(
                systemName: "battery.100percent.circle",
                variableValue: Double(button.batteryVoltage * 100.0) / 3
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(button.displayName)
                    .font(.subheadline.weight(.semibold))
            }
            
            Spacer()
            
            Group {
                if assignment.player1 == button.identifier.uuidString {
                    Text(assignment.display(for: .player1))
                }
                if assignment.player2 == button.identifier.uuidString {
                    Text(assignment.display(for: .player2))
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            Menu {
                // Assign to Player 1
                Button {
                    assignment.player1 = button.identifier.uuidString
                    assignment.save()
                } label: {
                    Text("Assign to " + assignment.display(for: .player1))
                }
                // Assign to Player 2
                Button {
                    assignment.player2 = button.identifier.uuidString
                    assignment.save()
                } label: {
                    Text("Assign to " + assignment.display(for: .player2))
                }
                
                Button {
                    Task {
                        await flicManager.forget(button)
                    }
                } label: {
                    Text("Forget")
                }
                
                /*Button {
                    Task {
                        await flicManager.rename(button, to:"New name")
                    }
                } label: {
                    Text("Rename")
                }*/
                
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
