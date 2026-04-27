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

    private var passwordMeetsMinimum: Bool {
        password.count >= 8
    }

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
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(TempoColor.primary.opacity(0.10))
                    .frame(width: 68, height: 68)
                Image(systemName: "figure.run")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(TempoColor.primary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Start Your Journey")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(TempoColor.ink)

                Text("Create an account to track your runs.")
                    .font(.subheadline)
                    .foregroundStyle(TempoColor.slate)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(TempoColor.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TempoColor.line, lineWidth: 1)
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
                    .foregroundStyle(password.isEmpty || passwordMeetsMinimum ? TempoColor.slate : .red)
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
                .disabled(auth.isLoading || !acceptsTerms || password != confirmPassword || !passwordMeetsMinimum)
              
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
