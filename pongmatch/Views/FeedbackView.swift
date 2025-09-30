import SwiftUI

struct FeedbackView : View {
    @EnvironmentObject private var auth: AuthViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var feedbackText: String = ""
    @State private var isSubmitted: Bool = false
    
    @StateObject private var submiteFeedback = ApiAction()

    var body: some View {
        VStack(spacing: 24) {
            if isSubmitted {
                VStack(spacing: 16) {
                    Text("Thank you for your feedback!")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    Text("We appreciate your input and will use it to improve Pongmatch.")
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: 12) {
                    Text("We'd love to hear from you!")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    Text("Tell us what features you'd love to see, or any feedback you have.")
                        .multilineTextAlignment(.center)
                }
                TextEditor(text: $feedbackText)
                    .frame(minHeight: 120, maxHeight: 180)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                Button(action: submitFeedback) {
                    if submiteFeedback.loading {
                        ProgressView()
                    } else {
                        Text("Send Feedback")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(submiteFeedback.loading || feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
    }

    private func submitFeedback() {
        guard !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        Task {            
            isSubmitted = await submiteFeedback.run {
                try await auth.api.sendFeedback(feedbackText)
            }
            
            if isSubmitted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    FeedbackView()
}
