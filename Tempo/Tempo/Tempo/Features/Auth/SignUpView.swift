import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptsTerms = true
    @State private var showsPassword = false
    @State private var showsConfirmPassword = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                formCard
            }
            .padding(20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 84, height: 84)
                .overlay {
                    Text("🎯")
                        .font(.system(size: 36))
                }
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                }

            Text("Start Your Journey")
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text("Create an account to track your runs")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .foregroundStyle(.white)
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [TempoColor.ink, TempoColor.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private var formCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                AuthField(title: "Full Name", systemImage: "person", text: $fullName, prompt: "John Doe")
                AuthField(title: "Email Address", systemImage: "envelope", text: $email, prompt: "your@email.com")

                AuthSecureField(
                    title: "Password",
                    systemImage: "lock",
                    text: $password,
                    showsText: $showsPassword,
                    prompt: "Create a password"
                )

                Text("Must be at least 8 characters")
                    .font(.caption)
                    .foregroundStyle(TempoColor.slate)
                    .padding(.top, -8)

                AuthSecureField(
                    title: "Confirm Password",
                    systemImage: "lock",
                    text: $confirmPassword,
                    showsText: $showsConfirmPassword,
                    prompt: "Confirm your password"
                )

                Toggle(isOn: $acceptsTerms) {
                    Text("I agree to the Terms of Service and Privacy Policy")
                        .font(.subheadline)
                        .foregroundStyle(TempoColor.ink)
                }
                .toggleStyle(.switch)

                Button("Create Account") {
                    Task {
                        await auth.signUp(
                            fullName: fullName,
                            email: email,
                            password: password
                        )
                    }
                }
                .buttonStyle(TempoPrimaryButtonStyle())
                .disabled(auth.isLoading || !acceptsTerms || password != confirmPassword)
              
                if let error = auth.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Divider()

                HStack(spacing: 12) {
                    socialButton(title: "Google", icon: "globe")
                    socialButton(title: "Apple", icon: "apple.logo")
                }

                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundStyle(TempoColor.slate)

                    NavigationLink("Sign In") {
                        LoginView()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(TempoColor.primary)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
    }

    private func socialButton(title: String, icon: String) -> some View {
        Button {
        } label: {
            Label(title, systemImage: icon)
                .font(.headline)
        }
        .buttonStyle(TempoSecondaryButtonStyle())
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
