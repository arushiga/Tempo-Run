import SwiftUI

struct AuthField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    let prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TempoColor.ink)

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(TempoColor.slate)

                TextField(prompt, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(TempoColor.surfaceStrong)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(TempoColor.line, lineWidth: 1)
            )
        }
    }
}

struct AuthSecureField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    @Binding var showsText: Bool
    let prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TempoColor.ink)

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(TempoColor.slate)

                Group {
                    if showsText {
                        TextField(prompt, text: $text)
                    } else {
                        SecureField(prompt, text: $text)
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    showsText.toggle()
                } label: {
                    Image(systemName: showsText ? "eye.slash" : "eye")
                        .foregroundStyle(TempoColor.slate)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(TempoColor.surfaceStrong)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(TempoColor.line, lineWidth: 1)
            )
        }
    }
}

#Preview {
    StatefulAuthPreview()
}

private struct StatefulAuthPreview: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showsPassword = false

    var body: some View {
        VStack(spacing: 16) {
            AuthField(title: "Email", systemImage: "envelope", text: $email, prompt: "name@example.com")
            AuthSecureField(title: "Password", systemImage: "lock", text: $password, showsText: $showsPassword, prompt: "Password")
        }
        .padding()
        .background(TempoGradient.appBackground)
    }
}
