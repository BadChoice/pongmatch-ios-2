import SwiftUI

struct ScoreboardSelectionView : View {
    
    enum ScoreboardMode: String, CaseIterable, Identifiable {
        var id: String { rawValue }
        case standard = "Standard Match"
        case otp = "One Time Code"
    }
    
    var onSelect: (Game) -> Void

    @EnvironmentObject private var auth: AuthViewModel
    
    @State private var initialScore:InitialScore = .standard
    @State private var winCondition:WinningCondition = .bestof3
    @State private var rankingType:RankingType = .friendly
    @State private var player2:User = User.unknown()
    
    @State private var searchingPlayer2 = false
    
    @State private var publicScoreboardCode = ""
    @State private var selectedMode: ScoreboardMode = .standard

    var body: some View {
        VStack(alignment: .leading) {
            
            Picker("Mode", selection: $selectedMode) {
                ForEach(ScoreboardMode.allCases) { mode in
                    Text(mode.rawValue)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical)
            
            if selectedMode == .standard {
                Group {
                    HStack{
                        CompactUserView(user: auth.user)
                            .frame(maxWidth: .infinity)
                        Spacer()
                        Text("VS").font(.title.bold())
                        Spacer()
                        Button {
                            searchingPlayer2 = true
                        } label: {
                            CompactUserView(user: player2)
                                .foregroundStyle(.black)
                        }
                        .frame(maxWidth: .infinity)
                    }.frame(minHeight: 100)
                    

                    GameTypeSelectionView(
                        initialScore: $initialScore,
                        winCondition: $winCondition,
                        rankingType: $rankingType
                    )
                    
                    
                    Spacer()
                    
                    Button {
                        onSelect(
                            Game(
                                ranking_type: rankingType,
                                winning_condition: winCondition,
                                status: .ongoing,
                                player1: auth.user,
                                player2: player2
                            )
                        )
                    } label:{
                        Label("START", systemImage: "play.fill")
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(.black)
                            .clipShape(.capsule)
                            .foregroundStyle(.white)
                    }
                    Text("Start a match with the selected values")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else if selectedMode == .otp {
                OneTimeCodeView() { game in
                    onSelect(game)
                }
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $searchingPlayer2) {
            SearchOpponentView(selectedFriend: $player2) { selected in
                player2 = selected
                searchingPlayer2 = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
    

}

private struct OneTimeCodeView : View {
    @EnvironmentObject private var auth: AuthViewModel
    @State var codeDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @State var errorMessage:String? = nil
    var onSelect: (Game) -> Void = { _ in }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(0..<6, id: \ .self) { i in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 2)
                            .frame(width: 44, height: 56)
                        Text(codeDigits[i])
                            .font(.title)
                            .frame(width: 44, height: 56)
                        TextField("", text: Binding(
                            get: { codeDigits[i] },
                            set: { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered.count > 1 {
                                    // Handle paste
                                    pasteCode(filtered, from: i)
                                    return
                                }
                                if filtered.isEmpty {
                                    codeDigits[i] = ""
                                } else {
                                    codeDigits[i] = String(filtered.prefix(1))
                                    if i < 5 {
                                        focusedIndex = i + 1
                                    }
                                }
                                if codeDigits.allSatisfy({ $0.count == 1 }) {
                                    searchGameWithScoreboardCode()
                                }
                            }
                        ))
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .multilineTextAlignment(.center)
                        .focused($focusedIndex, equals: i)
                        .frame(width: 44, height: 56)
                        .opacity(0.01)
                        .onChange(of: codeDigits[i]) { newValue, _ in
                            if newValue.isEmpty && i > 0 {
                                focusedIndex = i - 1
                            }
                        }
                    }
                }
            }
            .onAppear {
                focusedIndex = 0
            }
            Button(action: clearCode) {
                Text("Clear")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            Text("Enter the one time code to start it with the digital scoreboard")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    private func pasteCode(_ value: String, from index: Int) {
        let chars = Array(value.prefix(6 - index))
        for (offset, char) in chars.enumerated() {
            codeDigits[index + offset] = String(char)
        }
        let next = min(index + chars.count, 5)
        focusedIndex = next
        if codeDigits.allSatisfy({ $0.count == 1 }) {
            searchGameWithScoreboardCode()
        }
    }
    
    private func clearCode() {
        codeDigits = Array(repeating: "", count: 6)
        focusedIndex = 0
        errorMessage = nil
    }
    
    private func searchGameWithScoreboardCode() {
        let code = codeDigits.joined()
        guard code.count == 6 else { return }
        Task {
            do {
                let game = try await auth.api.getGame(publicScoreboardCode: code)
                await MainActor.run {
                    onSelect(game)
                }
            } catch {
                errorMessage = "\(error)"
            }
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.user = User.me()
    return ScoreboardSelectionView { game in }.environmentObject(auth)
}
