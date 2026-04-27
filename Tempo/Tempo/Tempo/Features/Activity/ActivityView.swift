import SwiftUI
import Charts

struct ActivityView: View {
    @Environment(AppDataStore.self) private var store
    @State private var selectedTab: ActivityTab = .day

    enum ActivityTab: String, CaseIterable {
        case day = "Day", three = "3-Day", weekly = "Weekly", monthly = "Monthly"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard
                Picker("View", selection: $selectedTab) {
                    ForEach(ActivityTab.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                tabContent
            }
            .padding(.horizontal, 24).padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Activity")
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(TempoColor.ink)
            Text("Your training history and trends.")
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

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .day:     DayView(store: store)
        case .three:   ThreeDayView(store: store)
        case .weekly:  WeeklyView(store: store)
        case .monthly: MonthlyView(store: store)
        }
    }
}

// MARK: - Day

private struct DayView: View {
    let store: AppDataStore
    private var todayISO: String { AppDataStore.dateToISO(Date()) }
    private var todayActs: [Activity] { store.activities.filter { $0.completionDate == todayISO } }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Today — \(AppDataStore.formatDisplayDate(todayISO))")
                    .font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                if todayActs.isEmpty {
                    emptyState("No runs logged today.")
                } else {
                    ForEach(todayActs) { a in
                        ActivityRowView(activity: a, store: store)
                        if a.id != todayActs.last?.id { Divider() }
                    }
                }
            }
        }
    }
}

// MARK: - 3-Day

private struct ThreeDayView: View {
    let store: AppDataStore

    private var days: [(label: String, iso: String, acts: [Activity])] {
        (0..<3).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let iso = AppDataStore.dateToISO(date)
            return (AppDataStore.formatDisplayDate(iso), iso, store.activities.filter { $0.completionDate == iso })
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Last 3 Days — Mileage").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                    Chart {
                        ForEach(days, id: \.iso) { d in
                            BarMark(x: .value("Day", d.label), y: .value("Miles", store.totalMiles(d.acts)))
                                .foregroundStyle(TempoColor.primary.gradient).cornerRadius(6)
                        }
                    }
                    .frame(height: 140).chartYAxis { AxisMarks(position: .leading) }
                }
            }
            ForEach(days, id: \.iso) { d in
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(d.label).font(.headline.weight(.semibold)).foregroundStyle(TempoColor.ink)
                        if d.acts.isEmpty {
                            Text("Rest day").font(.subheadline).foregroundStyle(TempoColor.slate)
                        } else {
                            ForEach(d.acts) { a in
                                ActivityRowView(activity: a, store: store)
                                if a.id != d.acts.last?.id { Divider() }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Weekly

private struct WeeklyView: View {
    let store: AppDataStore
    private var weekStart: String { AppDataStore.currentWeekStart() }
    private var weekActs: [Activity] { store.weekActivities(weekStart) }

    private struct DayBar: Identifiable { let id: String; let label: String; let miles: Double }
    private var barData: [DayBar] {
        let labels = ["M","T","W","R","F","S","S"]
        guard let start = AppDataStore.isoToDate(weekStart) else { return [] }
        return (0..<7).map { i in
            let iso = AppDataStore.dateToISO(start.addingTimeInterval(Double(i) * 86400))
            return DayBar(id: iso, label: labels[i], miles: store.totalMiles(store.activities.filter { $0.completionDate == iso }))
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("This Week").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                    HStack(spacing: 16) {
                        miniStat("Runs", "\(weekActs.count)")
                        miniStat("Miles", String(format: "%.1f", store.totalMiles(weekActs)))
                        miniStat("Avg Pace", store.formatPace(store.avgPaceSeconds(weekActs)))
                    }
                    Chart {
                        ForEach(barData) { d in
                            BarMark(x: .value("Day", d.label), y: .value("Miles", d.miles))
                                .foregroundStyle(TempoColor.secondary.gradient).cornerRadius(6)
                        }
                    }.frame(height: 120)
                }
            }
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Runs This Week").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                    if weekActs.isEmpty { emptyState("No runs this week yet.") }
                    else {
                        ForEach(weekActs) { a in
                            ActivityRowView(activity: a, store: store)
                            if a.id != weekActs.last?.id { Divider() }
                        }
                    }
                }
            }
        }
    }

    private func miniStat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.title3.weight(.bold)).foregroundStyle(TempoColor.ink)
            Text(label).font(.caption).foregroundStyle(TempoColor.slate)
        }.frame(maxWidth: .infinity)
    }
}

// MARK: - Monthly

private struct MonthlyView: View {
    let store: AppDataStore

    private var monthActs: [Activity] {
        let cal = Calendar.current
        guard let start = cal.date(from: cal.dateComponents([.year, .month], from: Date())) else { return [] }
        let iso = AppDataStore.dateToISO(start)
        return store.activities.filter { $0.completionDate >= iso }
    }

    private struct WeekBucket: Identifiable {
        let id: String; let label: String; let miles: Double; let avgPace: Int
    }
    private var buckets: [WeekBucket] {
        var ws = AppDataStore.currentWeekStart()
        var starts: [String] = []
        for _ in 0..<4 { starts.append(ws); ws = AppDataStore.shiftWeek(ws, by: -1) }
        return starts.reversed().map { w in
            let acts = store.weekActivities(w)
            return WeekBucket(id: w, label: AppDataStore.formatDisplayDate(w),
                              miles: store.totalMiles(acts), avgPace: store.avgPaceSeconds(acts))
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Monthly Mileage").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                    Chart {
                        ForEach(buckets) { b in
                            AreaMark(x: .value("Week", b.label), y: .value("Miles", b.miles))
                                .foregroundStyle(TempoColor.primary.opacity(0.15))
                            LineMark(x: .value("Week", b.label), y: .value("Miles", b.miles))
                                .foregroundStyle(TempoColor.primary).lineStyle(StrokeStyle(lineWidth: 2)).symbol(.circle)
                        }
                    }.frame(height: 140)
                }
            }
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Breakdown").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                    ForEach(buckets.reversed()) { b in
                        HStack {
                            Text(b.label).font(.subheadline).foregroundStyle(TempoColor.ink)
                            Spacer()
                            Text(String(format: "%.1f mi", b.miles)).font(.subheadline.weight(.semibold)).foregroundStyle(TempoColor.primary)
                            if b.avgPace > 0 {
                                Text("· \(store.formatPace(b.avgPace))/mi").font(.caption).foregroundStyle(TempoColor.slate)
                            }
                        }
                    }
                }
            }
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("This Month's Runs").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                    if monthActs.isEmpty { emptyState("No runs this month yet.") }
                    else {
                        ForEach(monthActs.prefix(10)) { a in
                            ActivityRowView(activity: a, store: store)
                            if a.id != monthActs.prefix(10).last?.id { Divider() }
                        }
                    }
                }
            }
        }
    }
}

private func emptyState(_ message: String) -> some View {
    Label(message, systemImage: "figure.run.circle").font(.subheadline).foregroundStyle(TempoColor.slate)
}

#Preview { NavigationStack { ActivityView() } }
