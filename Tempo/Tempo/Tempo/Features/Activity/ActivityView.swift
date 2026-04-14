import SwiftUI
import Charts

struct ActivityView: View {
    @Environment(AppDataStore.self) private var store
    @State private var selectedTab: ActivityTab = .day

    enum ActivityTab: String, CaseIterable {
        case day    = "Day"
        case three  = "3-Day"
        case weekly = "Weekly"
        case monthly = "Monthly"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                tabPicker
                tabContent
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Activity")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Your training history and trends.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(TempoGradient.hero)
        )
        .shadow(color: TempoColor.primary.opacity(0.24), radius: 18, y: 10)
    }

    private var tabPicker: some View {
        Picker("View", selection: $selectedTab) {
            ForEach(ActivityTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .day:    DayView(store: store)
        case .three:  ThreeDayView(store: store)
        case .weekly: WeeklyView(store: store)
        case .monthly: MonthlyView(store: store)
        }
    }
}

// MARK: - Day View

private struct DayView: View {
    let store: AppDataStore
    private var todayISO: String { AppDataStore.dateToISO(Date()) }
    private var todayActs: [Activity] {
        store.activities.filter { $0.completionDate == todayISO }
    }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Today — \(AppDataStore.formatDisplayDate(todayISO))")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                if todayActs.isEmpty {
                    emptyState(message: "No runs logged today.")
                } else {
                    ForEach(todayActs) { act in
                        ActivityRowView(activity: act, store: store)
                        if act.id != todayActs.last?.id { Divider() }
                    }
                }
            }
        }
    }
}

// MARK: - 3-Day View

private struct ThreeDayView: View {
    let store: AppDataStore

    private var days: [(label: String, iso: String, acts: [Activity])] {
        (0..<3).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let iso = AppDataStore.dateToISO(date)
            let acts = store.activities.filter { $0.completionDate == iso }
            return (label: AppDataStore.formatDisplayDate(iso), iso: iso, acts: acts)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Last 3 Days — Mileage")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(TempoColor.ink)

                    Chart {
                        ForEach(days, id: \.iso) { day in
                            BarMark(
                                x: .value("Day", day.label),
                                y: .value("Miles", store.totalMiles(day.acts))
                            )
                            .foregroundStyle(TempoColor.primary.gradient)
                            .cornerRadius(6)
                        }
                    }
                    .frame(height: 140)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                }
            }

            ForEach(days, id: \.iso) { day in
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(day.label)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(TempoColor.ink)
                        if day.acts.isEmpty {
                            Text("Rest day")
                                .font(.subheadline)
                                .foregroundStyle(TempoColor.slate)
                        } else {
                            ForEach(day.acts) { act in
                                ActivityRowView(activity: act, store: store)
                                if act.id != day.acts.last?.id { Divider() }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Weekly View

private struct WeeklyView: View {
    let store: AppDataStore

    private var weekStart: String { AppDataStore.currentWeekStart() }
    private var weekActs: [Activity] { store.weekActivities(weekStart) }

    private struct DayBar: Identifiable {
        let id: String
        let label: String
        let miles: Double
    }

    private var barData: [DayBar] {
        let labels = ["M","T","W","R","F","S","S"]
        guard let start = AppDataStore.isoToDate(weekStart) else { return [] }
        return (0..<7).map { i in
            let date = start.addingTimeInterval(Double(i) * 86400)
            let iso = AppDataStore.dateToISO(date)
            let miles = store.totalMiles(store.activities.filter { $0.completionDate == iso })
            return DayBar(id: iso, label: labels[i], miles: miles)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("This Week")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(TempoColor.ink)

                    HStack(spacing: 16) {
                        miniStat(label: "Runs", value: "\(weekActs.count)")
                        miniStat(label: "Miles", value: String(format: "%.1f", store.totalMiles(weekActs)))
                        miniStat(label: "Avg Pace", value: store.formatPace(store.avgPaceSeconds(weekActs)))
                    }

                    Chart {
                        ForEach(barData) { d in
                            BarMark(
                                x: .value("Day", d.label),
                                y: .value("Miles", d.miles)
                            )
                            .foregroundStyle(TempoColor.secondary.gradient)
                            .cornerRadius(6)
                        }
                    }
                    .frame(height: 120)
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Runs This Week")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(TempoColor.ink)

                    if weekActs.isEmpty {
                        emptyState(message: "No runs this week yet.")
                    } else {
                        ForEach(weekActs) { act in
                            ActivityRowView(activity: act, store: store)
                            if act.id != weekActs.last?.id { Divider() }
                        }
                    }
                }
            }
        }
    }

    private func miniStat(label: String, value: String) -> some View {
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
}

// MARK: - Monthly View

private struct MonthlyView: View {
    let store: AppDataStore

    private var monthActs: [Activity] {
        let cal = Calendar.current
        let now = Date()
        guard let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: now)) else { return [] }
        let isoStart = AppDataStore.dateToISO(monthStart)
        return store.activities.filter { $0.completionDate >= isoStart }
    }

    private struct WeekBucket: Identifiable {
        let id: String   // weekStart ISO
        let label: String
        let miles: Double
        let avgPace: Int
    }

    private var weekBuckets: [WeekBucket] {
        var buckets: [WeekBucket] = []
        var current = AppDataStore.currentWeekStart()
        // go back 4 weeks
        var starts: [String] = []
        for _ in 0..<4 {
            starts.append(current)
            current = AppDataStore.shiftWeek(current, by: -1)
        }
        for ws in starts.reversed() {
            let acts = store.weekActivities(ws)
            buckets.append(WeekBucket(
                id: ws,
                label: AppDataStore.formatDisplayDate(ws),
                miles: store.totalMiles(acts),
                avgPace: store.avgPaceSeconds(acts)
            ))
        }
        return buckets
    }

    var body: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Monthly Mileage")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(TempoColor.ink)

                    Chart {
                        ForEach(weekBuckets) { bucket in
                            AreaMark(
                                x: .value("Week", bucket.label),
                                y: .value("Miles", bucket.miles)
                            )
                            .foregroundStyle(TempoColor.primary.opacity(0.15))
                            LineMark(
                                x: .value("Week", bucket.label),
                                y: .value("Miles", bucket.miles)
                            )
                            .foregroundStyle(TempoColor.primary)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .symbol(.circle)
                        }
                    }
                    .frame(height: 140)
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Breakdown")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(TempoColor.ink)

                    ForEach(weekBuckets.reversed()) { bucket in
                        HStack {
                            Text(bucket.label)
                                .font(.subheadline)
                                .foregroundStyle(TempoColor.ink)
                            Spacer()
                            Text(String(format: "%.1f mi", bucket.miles))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(TempoColor.primary)
                            Text(bucket.avgPace > 0 ? "· \(store.formatPace(bucket.avgPace))/mi" : "")
                                .font(.caption)
                                .foregroundStyle(TempoColor.slate)
                        }
                    }
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("This Month's Runs")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(TempoColor.ink)

                    if monthActs.isEmpty {
                        emptyState(message: "No runs this month yet.")
                    } else {
                        ForEach(monthActs.prefix(10)) { act in
                            ActivityRowView(activity: act, store: store)
                            if act.id != monthActs.prefix(10).last?.id { Divider() }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Empty state helper

private func emptyState(message: String) -> some View {
    HStack {
        Image(systemName: "figure.run.circle")
            .foregroundStyle(TempoColor.slate)
        Text(message)
            .font(.subheadline)
            .foregroundStyle(TempoColor.slate)
    }
}

#Preview {
    NavigationStack {
        ActivityView()
    }
}
