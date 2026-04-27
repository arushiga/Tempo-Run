import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = true
    @State private var showsPassword = false
    @State private var resetEmailSent = false


    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                formCard
//                footer
            }
            .padding(20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Login")
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
                Text("Welcome Back")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(TempoColor.ink)

                Text("Sign in to continue your training.")
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
                AuthField(title: "Email Address", systemImage: "envelope", text: $email, prompt: "your@email.com")

                AuthSecureField(
                    title: "Password",
                    systemImage: "lock",
                    text: $password,
                    showsText: $showsPassword,
                    prompt: "Enter your password"
                )

                HStack {
                    Toggle("Remember me", isOn: $rememberMe)
                        .toggleStyle(.switch)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(TempoColor.ink)

                    Spacer()

                    Button("Forgot Password?") {
                      Task {
                              await auth.resetPassword(email: email)
                              if auth.errorMessage == nil {
                                  resetEmailSent = true
                              }
                          }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TempoColor.primary)
                }
                
                if resetEmailSent {
                    Text("Password reset email sent — check your inbox.")
                        .font(.caption)
                        .foregroundStyle(TempoColor.secondary)
                }

                Button("Sign In") {
                    Task {
                        await auth.signIn(email: email, password: password)
                    }
                }
                .buttonStyle(TempoPrimaryButtonStyle())
                .disabled(auth.isLoading)
                
                if let error = auth.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
              
                Divider()

//                Text("or continue with")
//                    .font(.subheadline.weight(.medium))
//                    .foregroundStyle(TempoColor.slate)
//                    .frame(maxWidth: .infinity)
//
//                HStack(spacing: 12) {
//                    socialButton(title: "Google", icon: "globe")
//                    socialButton(title: "Apple", icon: "apple.logo")
//                }

                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundStyle(TempoColor.slate)

                    NavigationLink("Sign Up") {
                        SignUpView()
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

//    private var footer: some View {
//        Text("Prototype only: Firebase Auth wiring comes next.")
//            .font(.caption)
//            .foregroundStyle(TempoColor.slate)
//            .padding(.bottom, 12)
//    }

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
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
