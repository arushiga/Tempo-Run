import SwiftUI
import FirebaseAuth

struct ProfilePrototypeView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                profileHeader
                accountDetailsCard
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

    private func initials(from name: String?) -> String {
        guard let name = name, !name.isEmpty else { return "?" }

        let components = name.split(separator: " ")

        let first = components.first?.first
        let last = components.count > 1 ? components.last?.first : nil

        return "\(first.map { String($0) } ?? "")\(last.map { String($0) } ?? "")".uppercased()
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "Not available" }

        return date.formatted(
            .dateTime
                .month(.abbreviated)
                .day()
                .year()
        )
    }

    private var profileHeader: some View {
        GlassCard {
            HStack(spacing: 16) {
                Circle()
                    .fill(TempoGradient.hero)
                    .frame(width: 76, height: 76)
                    .overlay {
                        Text(initials(from: auth.user?.displayName))
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(auth.user?.displayName ?? "Tempo Runner")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(TempoColor.ink)

                    Text(auth.user?.email ?? "Tempo Runner")
                        .font(.subheadline)
                        .foregroundStyle(TempoColor.slate)
                }
            }
        }
    }

    private var accountDetailsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Account Details")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                detailRow(title: "Email", value: auth.user?.email ?? "Not available")
                detailRow(title: "Member Since", value: formattedDate(auth.user?.metadata.creationDate))
                detailRow(title: "Last Sign-In", value: formattedDate(auth.user?.metadata.lastSignInDate))
                detailRow(title: "Email Verified", value: auth.user?.isEmailVerified == true ? "Yes" : "No")
            }
        }
    }

    private var dataSections: some View {
        VStack(alignment: .leading, spacing: 20) {
            section(
                title: "Training Snapshot",
                detail: "Goal Race: --\nWeekly Mileage Goal:\nPreferred Long Run Day:"
            )
            section(
                title: "Preferences",
                detail: "Home Base:\nFavorite Route:\nPreferred Time:"
            )
            section(
                title: "Friends / Connections",
                detail: "Saved running partners:\nShared training group:\nFirestore-backed social records can live here later."
            )
            section(
                title: "Past Runs by Date",
                detail: "Most recent run:\nWeekly summary:\nCalendar history:"
            )
            section(
                title: "Training Plan Progress",
                detail: "Current Block:\nWeek:\nCompletion:"
            )
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

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TempoColor.ink)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundStyle(TempoColor.slate)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        ProfilePrototypeView()
            .environmentObject(AuthViewModel())
    }
}
