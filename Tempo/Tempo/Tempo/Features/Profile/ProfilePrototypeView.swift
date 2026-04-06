import SwiftUI

struct ProfilePrototypeView: View {
  @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                profileHeader
                dataSections
                Button("Log Out") {
                                auth.signOut()
                            }
                            .buttonStyle(TempoPrimaryButtonStyle())
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                }
                .padding(20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Profile")
    }

    private var profileHeader: some View {
        GlassCard {
            HStack(spacing: 16) {
                Circle()
                    .fill(TempoGradient.hero)
                    .frame(width: 76, height: 76)
                    .overlay {
                        Text("TJ")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Tempo Runner")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(TempoColor.ink)

                    Text("Friends, past activities, and training progress will render here from Firestore.")
                        .font(.subheadline)
                        .foregroundStyle(TempoColor.slate)
                }
            }
        }
    }

    private var dataSections: some View {
        VStack(alignment: .leading, spacing: 20) {
            section(title: "Friends / Connections", detail: "Render a list of friend records from Firestore.")
            section(title: "Past Runs by Date", detail: "Group activity history chronologically.")
            section(title: "Training Plan Progress", detail: "Use progress views to visualize completion state.")
        }
    }

    private func section(title: String, detail: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(TempoColor.slate)

                ProgressView(value: 0.55)
                    .tint(TempoColor.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfilePrototypeView()
    }
}
