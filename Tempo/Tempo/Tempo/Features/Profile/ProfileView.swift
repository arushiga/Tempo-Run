import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(AppDataStore.self) private var store

    private var allActs: [Activity] { store.activities }
    private var totalRuns: Int { allActs.count }
    private var totalMiles: Double { store.totalMiles(allActs) }
    private var totalSecs: Int { allActs.reduce(0) { $0 + $1.durationSeconds } }
    private var allTimeAvgPace: String {
        let s = store.avgPaceSeconds(allActs)
        return s > 0 ? store.formatPace(s) : "--:--"
    }
    private var weekActs: [Activity] { store.weekActivities(AppDataStore.currentWeekStart()) }
    private var weekMiles: Double { store.totalMiles(weekActs) }
    private var mostRecent: Activity? { store.mostRecentActivity() }
    private var weeklyReview: WeeklyReview { store.weeklyReview(weekStart: AppDataStore.currentWeekStart()) }
    private var memberSinceText: String {
        guard let date = auth.user?.metadata.creationDate else { return "Member since --/--/----" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return "Member since \(formatter.string(from: date))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard
                profileHeaderCard
                trainingSnapshotCard
                weeklyPlannerReviewCard
                allTimeStatsCard
                achievementsCard
                Button("Log Out") { auth.signOut(store: store) }
                    .buttonStyle(TempoPrimaryButtonStyle())
            }
            .padding(.horizontal, 24).padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Profile")
        .task {
                await store.loadActivitiesFromFirebase()
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profile")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(TempoColor.ink)
            Text("Your stats, progress, and achievements.")
                .font(.subheadline)
                .foregroundStyle(TempoColor.slate)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(TempoColor.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TempoColor.line, lineWidth: 1)
        )
    }

    // MARK: - Profile Header

    private var profileHeaderCard: some View {
        GlassCard {
            HStack(spacing: 16) {
                Circle()
                    .fill(TempoColor.primary)
                    .frame(width: 72, height: 72)
                    .overlay {
                        Text(initials(from: auth.user?.displayName))
                            .font(.title2.weight(.bold)).foregroundStyle(.white)
                    }
                VStack(alignment: .leading, spacing: 4) {
                    Text(auth.user?.displayName ?? "Tempo Runner")
                        .font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                    Text(auth.user?.email ?? "")
                        .font(.subheadline).foregroundStyle(TempoColor.slate)
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(TempoColor.secondary)
                            .font(.caption)
                        Text(memberSinceText)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(TempoColor.secondary)
                    }
                }
                Spacer()
            }
        }
    }

    // MARK: - Training Snapshot

    private var trainingSnapshotCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Training Snapshot").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                HStack(spacing: 16) {
                    snapshotStat("This Week", String(format: "%.1f mi", weekMiles))
                    snapshotStat("Runs", "\(weekActs.count)")
                    snapshotStat("Avg Pace", store.formatPace(store.avgPaceSeconds(weekActs)))
                }
                if let r = mostRecent {
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Most Recent Run").font(.caption).foregroundStyle(TempoColor.slate)
                        ActivityRowView(activity: r, store: store)
                    }
                }
            }
        }
    }

    private func snapshotStat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.title3.weight(.bold)).foregroundStyle(TempoColor.ink)
            Text(label).font(.caption).foregroundStyle(TempoColor.slate)
        }.frame(maxWidth: .infinity)
    }

    // MARK: - Weekly Planner Review

    private var weeklyPlannerReviewCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Weekly Planner Review")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                HStack(spacing: 12) {
                    plannerReviewStat("Plan Load", "\(weeklyReview.plannedLoad)")
                    plannerReviewStat("Plan Intensity", "\(weeklyReview.plannedIntensity)")
                    plannerReviewStat("Completion", "\(Int(weeklyReview.completionFraction * 100))%")
                }

                GoalProgressRow(
                    label: "Training Progress",
                    current: Double(weeklyReview.completedPlannedRunCount),
                    goal: Double(max(weeklyReview.plannedRunCount, 1)),
                    unit: "runs",
                    color: TempoColor.primary
                )

                let completedTypes = weeklyReview.completedCounts
                    .filter { $0.value > 0 }
                    .sorted { $0.key.shortLabel < $1.key.shortLabel }

                if !completedTypes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Completed by Type")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(TempoColor.slate)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(completedTypes, id: \.key) { type, count in
                                    Label("\(count) \(type.shortLabel)", systemImage: type.symbolName)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(type.color)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(type.color.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func plannerReviewStat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(TempoColor.ink)
            Text(label)
                .font(.caption)
                .foregroundStyle(TempoColor.slate)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - All-Time Stats

    private var allTimeStatsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("All-Time Stats").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(icon: "figure.run",   value: "\(totalRuns)",
                             label: "Total Runs",   color: TempoColor.primary)
                    StatCard(icon: "map",           value: String(format: "%.1f mi", totalMiles),
                             label: "Total Miles",  color: TempoColor.secondary)
                    StatCard(icon: "clock",         value: store.formatDuration(totalSecs),
                             label: "Total Time",   color: TempoColor.accent)
                    StatCard(icon: "speedometer",   value: "\(allTimeAvgPace)/mi",
                             label: "Avg Pace",     color: TempoColor.warmAccent)
                }
            }
        }
    }

    // MARK: - Achievements

    private var achievementsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Achievements").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                achievement("First Run", icon: "figure.run", unlocked: totalRuns >= 1, detail: "Log your first run")
                achievement("5 Run Streak", icon: "flame.fill", unlocked: totalRuns >= 5, detail: "Complete 5 runs")
                achievement("10 Miles Club", icon: "location.fill", unlocked: totalMiles >= 10, detail: "Run 10 total miles")
                achievement("25 Miles Club", icon: "bolt.heart.fill", unlocked: totalMiles >= 25, detail: "Run 25 total miles")
                achievement("100 Miles", icon: "target", unlocked: totalMiles >= 100, detail: "Run 100 total miles")
            }
        }
    }

    private func achievement(_ title: String, icon: String, unlocked: Bool, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: unlocked ? "checkmark.seal.fill" : icon)
                .font(.title3)
                .foregroundStyle(unlocked ? TempoColor.secondary : TempoColor.slate)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                    .foregroundStyle(unlocked ? TempoColor.ink : TempoColor.slate)
                Text(detail).font(.caption).foregroundStyle(TempoColor.slate)
            }
            Spacer()
        }
    }

    // MARK: - Helpers

    private func initials(from name: String?) -> String {
        guard let name, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last  = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (first + last).uppercased()
    }
}

#Preview {
    NavigationStack { ProfileView() }
        .environmentObject(AuthViewModel())
        .environment(AppDataStore())
}
