// WhatsNewView.swift
import SwiftUI

struct WhatsNewFeature: Identifiable {
    let id = UUID()
    let symbol: String
    let title: String
    let subtitle: String
}

struct WhatsNewView: View {
    let features = [
        WhatsNewFeature(
            symbol: "applewatch",
            title: "Digital Scoreboard for Your Games",
            subtitle: "Enjoy the convenience of a digital scoreboard for all your ping pong games.",
        ),
        WhatsNewFeature(
            symbol: "circle.fill",
            title: "Added support for Flic buttons",
            subtitle: "Attach them to the table and have joy updating the scoreboard.",
        ),
        WhatsNewFeature(
            symbol: "sportscourt",
            title: "Track your matches",
            subtitle: "Log games, results and keep your ELO up to date.",
        ),
        WhatsNewFeature(
            symbol: "person.2.fill",
            title: "Build Your Ping Pong Community",
            subtitle: "Forge lasting connections by creating groups of friends who share your passion for ping pong.",
        ),
        WhatsNewFeature(
            symbol: "chart.xyaxis.line",
            title: "Climb the Global Ranks",
            subtitle: "Compete on a worldwide stage with our Global Elo Ranking system. See where you stand in the international community.",
        )
    ]
    
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Header().padding(.vertical, 42)
                
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(features) { feature in
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: feature.symbol)
                                .font(.system(size: 28, weight: .semibold))
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(feature.title)
                                    .font(.headline)
                                Text(feature.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Label("Start playing", systemImage: "figure.table.tennis")
                        .padding(.vertical, 6)
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled()
        .presentationDetents([.large])
    }
    
    private struct Header: View {
        var body: some View {
            VStack(spacing: 12) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48)
                
                    Text("Welcome to Pongmatch")
                    .font(.title2.bold())
                
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Version \(version)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

            }
        }
    }
}

enum WhatsNewManager {
    private static let key = "WhatsNew.lastShownVersion"
    
    static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }
    
    static func shouldShow() -> Bool {
        let last = UserDefaults.standard.string(forKey: key)
        return last != currentVersion
    }
    
    static func markShown() {
        UserDefaults.standard.set(currentVersion, forKey: key)
    }
}

#Preview {
    @Previewable @State var showModal = true
    NavigationStack { }.sheet(isPresented: $showModal){
        WhatsNewView {}
    }
}
