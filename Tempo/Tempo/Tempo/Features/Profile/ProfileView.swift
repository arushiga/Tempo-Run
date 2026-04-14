import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(AppDataStore.self) private var store

    private var weekStart: String { AppDataStore.currentWeekStart() }
    private var weekActs: [Activity] { store.weekActivities(weekStart) }
    private var allActs: [Activity] { store.activities }
    private var recent: Activity? { store.mostRecentActivity() }

    private var level: Int { allActs.count / 5 + 1 }
    private var totalRuns: Int { allActs.count }
    private var totalMiles: Double { store.totalMiles(allActs) }
    private var totalSecs: Int { allActs.reduce(0) { $0 + $1.durationSeconds } }
    private var avgPace: String {
        let secs = store.avgPaceSeconds(allActs)
        return secs > 0 ? store.formatPace(secs) : "--:--"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                profileHeader
                trainingSnapshot
                planProgress
                allTimeStats
                signOutButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Profile")
    }

    // MARK: - Header

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

                    Text(auth.user?.email ?? "")
                        .font(.subheadline)
                        .foregroundStyle(TempoColor.slate)

                    Text("Level \(level) Runner")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(TempoColor.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(TempoColor.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Training Snapshot

    private var trainingSnapshot: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Training Snapshot")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                snapshotRow(
                    label: "This Week",
                    value: String(format: "%.1f mi · %d runs", store.totalMiles(weekActs), weekActs.count)
                )

                if let recent {
                    snapshotRow(label: "Last Run", value: recent.name)
                    snapshotRow(
                        label: "Distance",
                        value: String(format: "%.1f mi · %@/mi", recent.distanceMiles,
                                      store.formatPace(recent.avgPaceSecondsPerMile))
                    )
                    snapshotRow(label: "Date", value: AppDataStore.formatDisplayDate(recent.completionDate))
                } else {
                    Text("No runs logged yet.")
                        .font(.subheadline)
                        .foregroundStyle(TempoColor.slate)
                }
            }
        }
    }

    // MARK: - Plan Progress

    private var planProgress: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Training Plan Progress")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                let completionPct = weekActs.count > 0
                    ? min(Double(weekActs.count) / 5.0, 1.0)
                    : 0

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Weekly Completion")
                            .font(.subheadline)
                            .foregroundStyle(TempoColor.ink)
                        Spacer()
                        Text("\(Int(completionPct * 100))%")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(TempoColor.primary)
                    }
                    ProgressView(value: completionPct)
                        .tint(TempoColor.primary)
                }

                Divider()

                snapshotRow(label: "Weekly Load",
                            value: String(format: "%.0f%% of goal", min(store.totalMiles(weekActs) / 25.0 * 100, 100)))
                snapshotRow(label: "Intensity",
                            value: weekActs.contains(where: { $0.category == .tempo || $0.category == .race }) ? "High" : "Moderate")
            }
        }
    }

    // MARK: - All-Time Stats

    private var allTimeStats: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("All-Time Stats")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(icon: "figure.run",  value: "\(totalRuns)", label: "Total Runs", color: TempoColor.primary)
                    StatCard(icon: "map",          value: String(format: "%.0f mi", totalMiles), label: "Total Miles", color: TempoColor.secondary)
                    StatCard(icon: "clock",        value: store.formatDuration(totalSecs), label: "Total Time", color: TempoColor.accent)
                    StatCard(icon: "speedometer",  value: "\(avgPace)/mi", label: "Avg Pace", color: TempoColor.warmAccent)
                }
            }
        }
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button("Sign Out") {
            auth.signOut()
        }
        .buttonStyle(TempoSecondaryButtonStyle())
        .padding(.bottom, 16)
    }

    // MARK: - Helpers

    private func snapshotRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(TempoColor.slate)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TempoColor.ink)
        }
    }

    private func initials(from name: String?) -> String {
        guard let name, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (first + last).uppercased()
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
