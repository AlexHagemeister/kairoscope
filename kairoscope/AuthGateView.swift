import SwiftUI

struct AuthGateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Kairoscope")
                .font(.largeTitle.weight(.semibold))

            Text("Sign in to sync your timeline across devices.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Sign in with Apple") {}
                    .buttonStyle(.borderedProminent)

                Button("Sign in with Google") {}
                    .buttonStyle(.bordered)
            }
            .disabled(true) // Enabled once real auth is wired (Milestone C).
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .foregroundStyle(Color(white: 0.9))
    }
}

#Preview {
    AuthGateView()
        .background(Color.black)
}
