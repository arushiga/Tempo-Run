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
                    StatCard(icon: "speedometer",  value: "\(weekAvgPace)/mi",                    label: "Avg Pace", color: TempoColor.warmAccent)
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
                GoalProgressRow(label: "All-Time Miles",  current: totalAllMiles,    goal: allTimeMileGoal,       unit: "mi",   color: TempoColor.accent)
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
