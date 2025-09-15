import SwiftUI

struct FeedbackView : View {
    @Environment(\.presentationMode) var presentationMode
    @State private var feedbackText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var isSubmitted: Bool = false

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
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
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
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Send Feedback")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(isSubmitting || feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
    }

    private func submitFeedback() {
        guard !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSubmitting = true
        // Simulate upload delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isSubmitting = false
            isSubmitted = true
            feedbackText = ""
        }
    }
}

#Preview {
    FeedbackView()
}
