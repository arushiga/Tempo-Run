import Foundation
import Observation
import FirebaseFirestore
import FirebaseAuth

struct DailyMileagePoint: Identifiable {
    let id: Int
    let dayIndex: Int
    let label: String
    let plannedMiles: Double
    let actualMiles: Double
}

struct WeeklyReview {
    let plannedRunCount: Int
    let completedPlannedRunCount: Int
    let plannedMiles: Double
    let actualMiles: Double
    let plannedLoad: Int
    let actualLoad: Int
    let plannedRelativeLoad: Int
    let actualRelativeLoad: Int
    let plannedIntensity: Int
    let actualIntensity: Int
    let completedCounts: [RunType: Int]

    var completionFraction: Double {
        guard plannedRunCount > 0 else { return 0 }
        return Double(completedPlannedRunCount) / Double(plannedRunCount)
    }
}

struct WeeklyStats: Codable {
    var weekStart: String
    var runs: Int
    var totalMiles: Double
    var totalSeconds: Int
    var avgPaceSeconds: Int
}

struct UserProfile: Codable {
    var fullName: String
    var email: String
    var weeklyMileageGoal: Double
    var weeklyRunGoal: Int
    var allTimeMileGoal: Double
}

@Observable
final class AppDataStore {
    private(set) var activities: [Activity] = []
    private var uid: String { Auth.auth().currentUser?.uid ?? "guest" }


    private let activitiesKey = "tempo_activities"
    private func weekKey(_ ws: String) -> String { "tempo_week_\(ws)" }

    init() { load() }

    // MARK: - Activities

    func addActivity(_ activity: Activity) {
        var all = activities
        all.insert(activity, at: 0)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: activitiesKey)
        }
        activities = all
        saveActivity(activity)
        saveWeeklyStats(weekStart: Self.currentWeekStart())
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: activitiesKey),
           let decoded = try? JSONDecoder().decode([Activity].self, from: data) {
           activities = decoded
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
        saveWeekPlanToFirebase(runs, weekStart: weekStart)
    }
    
    func saveWeekPlanToFirebase(_ runs: [ScheduledRun], weekStart: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let data = runs.map { run -> [String: Any] in
            [
                "id": run.id.uuidString,
                "type": run.type.rawValue,
                "day": run.day,
                "timeOfDay": run.timeOfDay.rawValue,
                "distanceMiles": run.distanceMiles
            ]
        }
        db.collection("users").document(uid)
            .collection("weekPlans").document(weekStart)
            .setData(["runs": data, "weekStart": weekStart])
    }

    func loadWeekPlanFromFirebase(_ weekStart: String) async -> [ScheduledRun] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        do {
            let doc = try await db.collection("users").document(uid)
                .collection("weekPlans").document(weekStart)
                .getDocument()
            guard let runsData = doc.data()?["runs"] as? [[String: Any]] else { return [] }
            return runsData.compactMap { dict -> ScheduledRun? in
                guard
                    let idStr = dict["id"] as? String, let id = UUID(uuidString: idStr),
                    let typeStr = dict["type"] as? String, let type_ = RunType(rawValue: typeStr),
                    let day = dict["day"] as? Int,
                    let todStr = dict["timeOfDay"] as? String, let tod = TimeOfDay(rawValue: todStr)
                else { return nil }
                let miles = (dict["distanceMiles"] as? Double) ?? Double(dict["distanceMiles"] as? Int ?? 0)
                return ScheduledRun(id: id, type: type_, day: day, timeOfDay: tod, distanceMiles: miles)
            }
        } catch {
            print("Failed to load week plan: \(error)")
            return []
        }
    }

    // MARK: - Computed Helpers

    func weekActivities(_ weekStart: String) -> [Activity] {
        guard let start = Self.isoToDate(weekStart) else { return [] }
        let end = start.addingTimeInterval(7 * 86400)
        return activities.filter {
            guard let d = Self.isoToDate($0.completionDate) else { return false }
            return d >= start && d < end
        }
    }

    func totalMiles(_ acts: [Activity]) -> Double {
        acts.reduce(0) { $0 + $1.distanceMiles }
    }

    func avgPaceSeconds(_ acts: [Activity]) -> Int {
        let totalSecs = acts.reduce(0) { $0 + $1.durationSeconds }
        let miles = totalMiles(acts)
        guard miles > 0 else { return 0 }
        return Int(Double(totalSecs) / miles)
    }

    func formatPace(_ secsPerMile: Int) -> String {
        guard secsPerMile > 0 else { return "--:--" }
        return String(format: "%d:%02d", secsPerMile / 60, secsPerMile % 60)
    }

    func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }

    func mostRecentActivity() -> Activity? {
        activities.max(by: { $0.completionDate < $1.completionDate })
    }

    func weeklyReview(weekStart: String, plannedRuns: [ScheduledRun]? = nil) -> WeeklyReview {
        let plannedRuns = plannedRuns ?? loadWeekPlan(weekStart)
        let currentWeekActivities = weekActivities(weekStart)
        let matchedActivities = matchedActivitiesForPlan(plannedRuns: plannedRuns, activities: currentWeekActivities)
        let previousWeekStart = Self.shiftWeek(weekStart, by: -1)
        let previousPlannedRuns = loadWeekPlan(previousWeekStart)
        let previousWeekActivities = weekActivities(previousWeekStart)

        var completedCounts: [RunType: Int] = [:]
        for activity in matchedActivities {
            let runType = runType(for: activity.category)
            completedCounts[runType, default: 0] += 1
        }

        let plannedLoadScore = loadScore(for: plannedRuns)
        let actualLoadScore = loadScore(for: matchedActivities)
        let previousPlannedLoadScore = loadScore(for: previousPlannedRuns)
        let previousActualLoadScore = loadScore(for: previousWeekActivities)

        return WeeklyReview(
            plannedRunCount: plannedRuns.count,
            completedPlannedRunCount: matchedActivities.count,
            plannedMiles: plannedRuns.reduce(0) { $0 + $1.distanceMiles },
            actualMiles: totalMiles(matchedActivities),
            plannedLoad: plannedLoadScore,
            actualLoad: actualLoadScore,
            plannedRelativeLoad: relativeLoadPercent(current: plannedLoadScore, previous: previousPlannedLoadScore),
            actualRelativeLoad: relativeLoadPercent(current: actualLoadScore, previous: previousActualLoadScore),
            plannedIntensity: intensityScore(for: plannedRuns),
            actualIntensity: intensityScore(for: matchedActivities),
            completedCounts: completedCounts
        )
    }

    func dailyMileagePoints(weekStart: String) -> [DailyMileagePoint] {
        let plannedRuns = loadWeekPlan(weekStart)
        let weekActivities = weekActivities(weekStart)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")

        return (0..<7).map { dayIndex in
            let dayISO = Self.shiftWeek(weekStart, by: 0)
            let date = Self.isoToDate(dayISO)?.addingTimeInterval(Double(dayIndex) * 86400)
            let isoDate = date.map { formatter.string(from: $0) } ?? weekStart
            let dayActivities = weekActivities.filter { $0.completionDate == isoDate }
            let label = shortWeekdayLabel(for: dayIndex)

            return DailyMileagePoint(
                id: dayIndex,
                dayIndex: dayIndex,
                label: label,
                plannedMiles: plannedRuns.filter { $0.day == dayIndex }.reduce(0) { $0 + $1.distanceMiles },
                actualMiles: totalMiles(dayActivities)
            )
        }
    }
  
    // MARK: - Firebase Sync
    func saveActivity(_ activity: Activity) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try db.collection("users").document(uid)
                .collection("activities").document(activity.id)
                .setData(from: activity)
        } catch {
            print("Failed to save activity: \(error)")
        }
    }

    func loadActivitiesFromFirebase() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await db.collection("users").document(uid)
                .collection("activities")
                .order(by: "completionDate", descending: true)
                .getDocuments()
            let fetched = try snapshot.documents.compactMap {
                try $0.data(as: Activity.self)
            }
            activities = fetched.isEmpty ? [] : fetched
            if let data = try? JSONEncoder().encode(fetched) {
                UserDefaults.standard.set(data, forKey: activitiesKey)
            }
            
        } catch {
            print("Failed to load activities: \(error)")
        }
    }

    private var db: Firestore { Firestore.firestore() }

    private func userStatsCollection() throws -> CollectionReference {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not logged in"])
        }
        return db.collection("users").document(uid).collection("weeklyStats")
    }

    func saveWeeklyStats(weekStart: String) {
        let acts = weekActivities(weekStart)
        let stats = WeeklyStats(
            weekStart: weekStart,
            runs: acts.count,
            totalMiles: totalMiles(acts),
            totalSeconds: acts.reduce(0) { $0 + $1.durationSeconds },
            avgPaceSeconds: avgPaceSeconds(acts)
        )
        do {
            try userStatsCollection()
                .document(weekStart)
                .setData(from: stats)
        } catch {
            print("Failed to save weekly stats: \(error)")
        }
    }

    func loadWeeklyStatsFromFirebase(weekStart: String) async -> WeeklyStats? {
        do {
            let doc = try await userStatsCollection()
                .document(weekStart)
                .getDocument()
            return try doc.data(as: WeeklyStats.self)
        } catch {
            print("Failed to load weekly stats: \(error)")
            return nil
        }
    }
  
    func saveProfile(_ profile: UserProfile) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try db.collection("users").document(uid).setData(from: profile, merge: true)
        } catch {
            print("Failed to save profile: \(error)")
        }
    }

    func loadProfile() async -> UserProfile? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            return try doc.data(as: UserProfile.self)
        } catch {
            print("Failed to load profile: \(error)")
            return nil
        }
    }
  
    func clearUserData() {
        activities = []
        UserDefaults.standard.removeObject(forKey: activitiesKey)
    }
  
    // MARK: - Static Date Utilities

    static func currentWeekStart() -> String {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        let monday = cal.date(from: comps) ?? Date()
        return dateToISO(monday)
    }

    static func shiftWeek(_ iso: String, by delta: Int) -> String {
        guard let date = isoToDate(iso) else { return iso }
        return dateToISO(date.addingTimeInterval(Double(delta) * 7 * 86400))
    }

    static func dateToISO(_ date: Date) -> String {
        isoFormatter.string(from: date)
    }

    static func isoToDate(_ iso: String) -> Date? {
        isoFormatter.date(from: iso)
    }

    static func formatDisplayDate(_ iso: String) -> String {
        guard let date = isoToDate(iso) else { return iso }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        fmt.timeZone = TimeZone(identifier: "UTC")
        return fmt.string(from: date)
    }

    static func parseDuration(_ input: String) -> Int? {
        let parts = input.split(separator: ":", omittingEmptySubsequences: false).map { Int($0) }
        guard !parts.isEmpty, parts.allSatisfy({ $0 != nil }) else { return nil }
        let vals = parts.compactMap { $0 }
        switch vals.count {
        case 3: return vals[0] * 3600 + vals[1] * 60 + vals[2]
        case 2: return vals[0] * 60 + vals[1]
        default: return nil
        }
    }

    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    private func matchedActivitiesForPlan(plannedRuns: [ScheduledRun], activities: [Activity]) -> [Activity] {
        var remaining = activities.sorted { lhs, rhs in
            lhs.completionDate < rhs.completionDate
        }
        var matches: [Activity] = []

        for run in plannedRuns {
            guard let index = remaining.firstIndex(where: { activity in
                activity.category.matches(run.type)
            }) else { continue }
            matches.append(remaining.remove(at: index))
        }

        return matches
    }

    private func loadScore(for runs: [ScheduledRun]) -> Int {
        Int(round(weightedLoad(for: runs) * 10))
    }

    private func loadScore(for activities: [Activity]) -> Int {
        Int(round(weightedLoad(for: activities) * 10))
    }

    private func intensityScore(for runs: [ScheduledRun]) -> Int {
        let miles = runs.reduce(0) { $0 + $1.distanceMiles }
        guard miles > 0 else { return 0 }
        let averageIntensity = weightedLoad(for: runs) / miles
        return Int(round((averageIntensity * 100) + min(miles * 2, 40)))
    }

    private func intensityScore(for activities: [Activity]) -> Int {
        let miles = totalMiles(activities)
        guard miles > 0 else { return 0 }
        let averageIntensity = weightedLoad(for: activities) / miles
        return Int(round((averageIntensity * 100) + min(miles * 2, 40)))
    }

    private func runType(for category: RunCategory) -> RunType {
        switch category {
        case .easy:
            .easy
        case .tempo:
            .tempo
        case .long:
            .longRun
        case .race:
            .race
        }
    }

    private func shortWeekdayLabel(for dayIndex: Int) -> String {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dayIndex]
    }

    private func relativeLoadPercent(current: Int, previous: Int) -> Int {
        guard previous > 0 else { return current > 0 ? 100 : 0 }
        return Int(round((Double(current) / Double(previous)) * 100))
    }

    private func weightedLoad(for runs: [ScheduledRun]) -> Double {
        runs.reduce(0) { partialResult, run in
            partialResult + (run.distanceMiles * intensityMultiplier(for: run.type))
        }
    }

    private func weightedLoad(for activities: [Activity]) -> Double {
        activities.reduce(0) { partialResult, activity in
            partialResult + (activity.distanceMiles * intensityMultiplier(for: activity.category))
        }
    }

    private func intensityMultiplier(for runType: RunType) -> Double {
        switch runType {
        case .easy:
            1.0
        case .longRun:
            1.15
        case .tempo:
            1.3
        case .race:
            1.55
        }
    }

    private func intensityMultiplier(for category: RunCategory) -> Double {
        switch category {
        case .easy:
            1.0
        case .long:
            1.15
        case .tempo:
            1.3
        case .race:
            1.55
        }
    }
}
