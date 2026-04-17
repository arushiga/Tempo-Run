import SwiftUI

struct HomeView: View {
    @Environment(AppDataStore.self) private var store

    private var weekStart: String { AppDataStore.currentWeekStart() }
    private var weekActs: [Activity] { store.weekActivities(weekStart) }
    private var weekMiles: Double { store.totalMiles(weekActs) }
    private var weekRuns: Int { weekActs.count }
    private var weekSecs: Int { weekActs.reduce(0) { $0 + $1.durationSeconds } }
    private var weekAvgPace: String {
        let s = store.avgPaceSeconds(weekActs)
        return s > 0 ? store.formatPace(s) : "--:--"
    }
    private var totalAllMiles: Double { store.totalMiles(store.activities) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard
                weekStatsSection
                goalsSection
                recentRunCard
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Tempo")
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dashboard")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(TempoColor.ink)
            Text("Week of \(AppDataStore.formatDisplayDate(weekStart))")
                .font(.headline)
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

    private var weekStatsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("This Week").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(icon: "figure.run",  value: "\(weekRuns)",                          label: "Runs",     color: TempoColor.primary)
                    StatCard(icon: "map",          value: String(format: "%.1f mi", weekMiles),   label: "Distance", color: TempoColor.secondary)
                    StatCard(icon: "clock",        value: store.formatDuration(weekSecs),          label: "Time",     color: TempoColor.accent)
                    StatCard(icon: "speedometer",  value: "\(weekAvgPace)/mi",                    label: "Avg Pace", color: TempoColor.warmAccent)
                }
            }
        }
    }

    private var goalsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Current Goals").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                GoalProgressRow(label: "Weekly Distance", current: weekMiles,       goal: 25,  unit: "mi",   color: TempoColor.primary)
                GoalProgressRow(label: "Runs This Week",  current: Double(weekRuns), goal: 5,   unit: "runs", color: TempoColor.secondary)
                GoalProgressRow(label: "All-Time Miles",  current: totalAllMiles,    goal: 500, unit: "mi",   color: TempoColor.accent)
            }
        }
    }

    private var recentRunCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Most Recent Run").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                if let recent = store.mostRecentActivity() {
                    ActivityRowView(activity: recent, store: store)
                } else {
                    Label("No runs logged yet.", systemImage: "figure.run.circle")
                        .font(.subheadline).foregroundStyle(TempoColor.slate)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { HomeView() }
}
