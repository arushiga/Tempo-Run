import SwiftUI

struct HomeView: View {
    @Environment(AppDataStore.self) private var store
    @State private var showingGoalsEditor = false

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
    private var weeklyMileageGoal: Double { store.profile.weeklyMileageGoal }
    private var weeklyRunGoal: Int { store.profile.weeklyRunGoal }
    private var allTimeMileGoal: Double { store.profile.allTimeMileGoal }
    private var trends: HistoricalTrendComparison { store.historicalTrendComparison(for: weekStart) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard
                weekStatsSection
                trendComparisonSection
                goalsSection
                recentRunCard
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Tempo")
        .sheet(isPresented: $showingGoalsEditor) {
            GoalsEditorSheet(isPresented: $showingGoalsEditor)
                .environment(store)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dashboard")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(TempoColor.ink)
            Text("Week of \(AppDataStore.formatDisplayDate(weekStart))")
                .font(.headline)
                .foregroundStyle(TempoColor.slate)
            Text("Turn past runs into smarter weekly training plans.")
                .font(.subheadline)
                .foregroundStyle(TempoColor.muted)
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
                    StatCard(icon: "clock",        value: store.formatDuration(weekSecs),          label: "Time",     color: TempoColor.ink)
                    StatCard(icon: "gauge.medium", value: "\(weekAvgPace)/mi",                    label: "Avg Pace", color: TempoColor.primary)
                }
            }
        }
    }

    private var goalsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Current Goals").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                    Spacer()
                    Button {
                        showingGoalsEditor = true
                    } label: {
                        Label("Edit", systemImage: "square.and.pencil")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(TempoColor.primary)
                }
                GoalProgressRow(label: "Weekly Distance", current: weekMiles,        goal: weeklyMileageGoal,      unit: "mi",   color: TempoColor.primary)
                GoalProgressRow(label: "Runs This Week",  current: Double(weekRuns), goal: Double(weeklyRunGoal), unit: "runs", color: TempoColor.secondary)
                GoalProgressRow(label: "All-Time Miles",  current: totalAllMiles,    goal: allTimeMileGoal,       unit: "mi",   color: TempoColor.ink)
            }
        }
    }

    private var trendComparisonSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Historical Trends")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                trendRow(
                    title: "Mileage",
                    current: String(format: "%.1f mi", trends.currentMiles),
                    previous: String(format: "%.1f mi", trends.previousMiles),
                    average: String(format: "%.1f mi", trends.fourWeekAverageMiles),
                    icon: "chart.bar.fill",
                    color: TempoColor.primary
                )

                trendRow(
                    title: "Runs",
                    current: "\(trends.currentRuns)",
                    previous: "\(trends.previousRuns)",
                    average: String(format: "%.1f", trends.fourWeekAverageRuns),
                    icon: "figure.run",
                    color: TempoColor.secondary
                )

                trendRow(
                    title: "Pace",
                    current: trendPaceText(trends.currentPaceSeconds),
                    previous: trendPaceText(trends.previousPaceSeconds),
                    average: trendPaceText(trends.fourWeekAveragePaceSeconds),
                    icon: "gauge.medium",
                    color: TempoColor.ink
                )
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

    private func trendRow(
        title: String,
        current: String,
        previous: String,
        average: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 34, height: 34)
                    .overlay {
                        Image(systemName: icon)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(color)
                    }

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)
            }

            HStack(spacing: 12) {
                trendValueCard(label: "This Week", value: current, emphasisColor: TempoColor.primary)
                trendValueCard(label: "Last Week", value: previous, emphasisColor: TempoColor.secondary)
                trendValueCard(label: "4-Week Avg", value: average, centerContent: true)
            }
        }
    }

    private func trendValueCard(
        label: String,
        value: String,
        emphasisColor: Color? = nil,
        centerContent: Bool = false
    ) -> some View {
        VStack(alignment: centerContent ? .center : .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(TempoColor.slate)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(centerContent ? .center : .leading)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(emphasisColor ?? TempoColor.ink)
                .multilineTextAlignment(centerContent ? .center : .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 74, maxHeight: 74, alignment: centerContent ? .center : .leading)
        .background(TempoColor.infoTile)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(TempoColor.line, lineWidth: 1)
        )
    }

    private func trendPaceText(_ seconds: Int) -> String {
        seconds > 0 ? "\(store.formatPace(seconds))/mi" : "--:--"
    }
}

private struct GoalsEditorSheet: View {
    @Binding var isPresented: Bool
    @Environment(AppDataStore.self) private var store

    @State private var weeklyMileageGoal = ""
    @State private var weeklyRunGoal = ""
    @State private var allTimeMileGoal = ""

    private var parsedWeeklyMileageGoal: Double? { Double(weeklyMileageGoal) }
    private var parsedWeeklyRunGoal: Int? { Int(weeklyRunGoal) }
    private var parsedAllTimeMileGoal: Double? { Double(allTimeMileGoal) }

    private var canSave: Bool {
        guard
            let weeklyMileageGoal = parsedWeeklyMileageGoal, weeklyMileageGoal > 0,
            let weeklyRunGoal = parsedWeeklyRunGoal, weeklyRunGoal > 0,
            let allTimeMileGoal = parsedAllTimeMileGoal, allTimeMileGoal > 0
        else {
            return false
        }

        return true
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Update your training goals to keep the dashboard and profile progress in sync.")
                        .font(.subheadline)
                        .foregroundStyle(TempoColor.slate)

                    goalField(
                        title: "Weekly Distance Goal",
                        text: $weeklyMileageGoal,
                        placeholder: "25.0",
                        suffix: "mi",
                        keyboard: .decimalPad
                    )

                    goalField(
                        title: "Runs This Week Goal",
                        text: $weeklyRunGoal,
                        placeholder: "5",
                        suffix: "runs",
                        keyboard: .numberPad
                    )

                    goalField(
                        title: "All-Time Miles Goal",
                        text: $allTimeMileGoal,
                        placeholder: "500",
                        suffix: "mi",
                        keyboard: .decimalPad
                    )
                }
                .padding(24)
            }
            .background(TempoGradient.appBackground.ignoresSafeArea())
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard
                            let weeklyMileageGoal = parsedWeeklyMileageGoal,
                            let weeklyRunGoal = parsedWeeklyRunGoal,
                            let allTimeMileGoal = parsedAllTimeMileGoal
                        else {
                            return
                        }

                        store.updateGoals(
                            weeklyMileageGoal: weeklyMileageGoal,
                            weeklyRunGoal: weeklyRunGoal,
                            allTimeMileGoal: allTimeMileGoal
                        )
                        isPresented = false
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                weeklyMileageGoal = goalText(for: store.profile.weeklyMileageGoal)
                weeklyRunGoal = "\(store.profile.weeklyRunGoal)"
                allTimeMileGoal = goalText(for: store.profile.allTimeMileGoal)
            }
        }
    }

    private func goalField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        suffix: String,
        keyboard: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TempoColor.ink)

            HStack(spacing: 10) {
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .textFieldStyle(TempoTextFieldStyle())
                Text(suffix)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TempoColor.slate)
            }
        }
    }

    private func goalText(for value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }
}

#Preview {
    NavigationStack { HomeView() }
}
