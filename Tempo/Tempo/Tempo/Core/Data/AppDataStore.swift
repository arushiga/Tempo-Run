import Foundation
import Observation

@Observable
final class AppDataStore {
    private(set) var activities: [Activity] = []

    private let activitiesKey = "tempo_activities"
    private func weekKey(_ ws: String) -> String { "tempo_week_\(ws)" }

    init() {
        load()
    }

    // MARK: - Activities

    func addActivity(_ activity: Activity) {
        var all = activities
        all.insert(activity, at: 0)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: activitiesKey)
        }
        activities = all
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: activitiesKey),
           let decoded = try? JSONDecoder().decode([Activity].self, from: data) {
            activities = decoded
        } else {
            activities = SeedData.activities
        }
    }

    // MARK: - Week Plans

    func loadWeekPlan(_ weekStart: String) -> [ScheduledRun] {
        guard let data = UserDefaults.standard.data(forKey: weekKey(weekStart)),
              let runs = try? JSONDecoder().decode([ScheduledRun].self, from: data)
        else { return [] }
        return runs
    }

    func saveWeekPlan(_ runs: [ScheduledRun], weekStart: String) {
        if let data = try? JSONEncoder().encode(runs) {
            UserDefaults.standard.set(data, forKey: weekKey(weekStart))
        }
    }

    // MARK: - Computed Helpers

    func weekActivities(_ weekStart: String) -> [Activity] {
        guard let start = Self.isoToDate(weekStart) else { return [] }
        let end = start.addingTimeInterval(7 * 86400)
        return activities.filter { a in
            guard let d = Self.isoToDate(a.completionDate) else { return false }
            return d >= start && d < end
        }
    }

    func totalMiles(_ acts: [Activity]) -> Double {
        acts.reduce(0) { $0 + $1.distanceMiles }
    }

    /// Correct avg pace: total seconds / total miles (not avg of per-run paces)
    func avgPaceSeconds(_ acts: [Activity]) -> Int {
        let totalSecs = acts.reduce(0) { $0 + $1.durationSeconds }
        let totalMi = totalMiles(acts)
        guard totalMi > 0 else { return 0 }
        return Int(Double(totalSecs) / totalMi)
    }

    func formatPace(_ secsPerMile: Int) -> String {
        guard secsPerMile > 0 else { return "--:--" }
        let m = secsPerMile / 60
        let s = secsPerMile % 60
        return String(format: "%d:%02d", m, s)
    }

    func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    func mostRecentActivity() -> Activity? {
        activities.max(by: { $0.completionDate < $1.completionDate })
    }

    func weekPlanCompletion(runs: [ScheduledRun], weekStart: String) -> Double {
        guard !runs.isEmpty else { return 0 }
        let wActs = weekActivities(weekStart)
        let scheduled = Double(runs.count)
        let completed = min(Double(wActs.count), scheduled)
        return completed / scheduled
    }

    // MARK: - Date Utilities

    static func currentWeekStart() -> String {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        let monday = cal.date(from: comps) ?? Date()
        return dateToISO(monday)
    }

    static func weekStart(for date: Date) -> String {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let monday = cal.date(from: comps) ?? date
        return dateToISO(monday)
    }

    static func shiftWeek(_ iso: String, by delta: Int) -> String {
        guard let date = isoToDate(iso) else { return iso }
        let shifted = date.addingTimeInterval(Double(delta) * 7 * 86400)
        return dateToISO(shifted)
    }

    static func dateToISO(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.timeZone = TimeZone(identifier: "UTC")
        return fmt.string(from: date)
    }

    static func isoToDate(_ iso: String) -> Date? {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.timeZone = TimeZone(identifier: "UTC")
        return fmt.date(from: iso)
    }

    static func formatDisplayDate(_ iso: String) -> String {
        guard let date = isoToDate(iso) else { return iso }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        fmt.timeZone = TimeZone(identifier: "UTC")
        return fmt.string(from: date)
    }

    /// Safe duration parsing — returns nil on malformed input (fixes React NaN bug)
    static func parseDuration(_ input: String) -> Int? {
        let parts = input.split(separator: ":", omittingEmptySubsequences: false)
                         .map { Int($0) }
        guard parts.allSatisfy({ $0 != nil }), !parts.isEmpty else { return nil }
        let vals = parts.compactMap { $0 }
        switch vals.count {
        case 3: return vals[0] * 3600 + vals[1] * 60 + vals[2]
        case 2: return vals[0] * 60 + vals[1]
        default: return nil
        }
    }
}
