import Foundation
import Observation
import FirebaseAuth
import FirebaseFirestore

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

struct HistoricalTrendComparison {
    let currentMiles: Double
    let previousMiles: Double
    let fourWeekAverageMiles: Double
    let currentRuns: Int
    let previousRuns: Int
    let fourWeekAverageRuns: Double
    let currentPaceSeconds: Int
    let previousPaceSeconds: Int
    let fourWeekAveragePaceSeconds: Int
}

struct UserProfile: Codable {
    var fullName: String
    var email: String
    var weeklyMileageGoal: Double
    var weeklyRunGoal: Int
    var allTimeMileGoal: Double

    static let defaultGoals = UserProfile(
        fullName: "",
        email: "",
        weeklyMileageGoal: 25,
        weeklyRunGoal: 5,
        allTimeMileGoal: 500
    )
}

@Observable
final class AppDataStore {
    private(set) var activities: [Activity] = []
    private(set) var profile = UserProfile.defaultGoals

    private var activeUserID: String?
    private var isBootstrappingUser = false

    private var currentUserID: String? {
        activeUserID ?? Auth.auth().currentUser?.uid
    }

    private var db: Firestore { Firestore.firestore() }

    init() {
        loadCachedActivities(for: nil)
    }

    // MARK: - Session

    func bootstrapForCurrentUser() async {
        guard let user = Auth.auth().currentUser else {
            clearUserData()
            return
        }

        if isBootstrappingUser, activeUserID == user.uid {
            return
        }

        isBootstrappingUser = true
        defer { isBootstrappingUser = false }

        activeUserID = user.uid
        loadCachedActivities(for: user.uid)

        await ensureUserDocument(for: user)
        await loadActivitiesFromFirebase()
        _ = await loadProfile()
        _ = await loadWeekPlan(Self.currentWeekStart())
    }

    func clearUserData() {
        activities = []
        profile = .defaultGoals
        activeUserID = nil
    }

    // MARK: - Activities

    func addActivity(_ activity: Activity) {
        var updated = activities.filter { $0.id != activity.id }
        updated.insert(activity, at: 0)
        updated.sort { $0.completionDate > $1.completionDate }
        activities = updated
        cacheActivities(updated, for: currentUserID)

        saveActivity(activity)
        if let weekStart = Self.weekStart(forISODate: activity.completionDate) {
            saveWeeklyStats(weekStart: weekStart)
        }
    }

    func updateActivity(_ activity: Activity) {
        guard let existing = activities.first(where: { $0.id == activity.id }) else {
            addActivity(activity)
            return
        }

        var updated = activities
        if let index = updated.firstIndex(where: { $0.id == activity.id }) {
            updated[index] = activity
        }
        updated.sort { $0.completionDate > $1.completionDate }
        activities = updated
        cacheActivities(updated, for: currentUserID)
        saveActivity(activity)

        let impactedWeeks = Set([
            Self.weekStart(forISODate: existing.completionDate),
            Self.weekStart(forISODate: activity.completionDate),
        ].compactMap { $0 })

        for weekStart in impactedWeeks {
            saveWeeklyStats(weekStart: weekStart)
        }
    }

    func deleteActivity(id: String) {
        guard let existing = activities.first(where: { $0.id == id }) else { return }

        activities.removeAll { $0.id == id }
        cacheActivities(activities, for: currentUserID)
        deleteActivityFromFirebase(id: id)

        if let weekStart = Self.weekStart(forISODate: existing.completionDate) {
            saveWeeklyStats(weekStart: weekStart)
        }
    }

    func loadActivitiesFromFirebase() async {
        guard let uid = currentUserID else {
            loadCachedActivities(for: nil)
            return
        }

        do {
            let snapshot = try await db.collection("users").document(uid)
                .collection("activities")
                .order(by: "completionDate", descending: true)
                .getDocuments()

            let fetched = snapshot.documents.compactMap(makeActivity(from:))
            activities = fetched
            cacheActivities(fetched, for: uid)
        } catch {
            print("Failed to load activities: \(error)")
            loadCachedActivities(for: uid)
        }
    }

    private func saveActivity(_ activity: Activity) {
        guard let uid = currentUserID else { return }

        db.collection("users").document(uid)
            .collection("activities").document(activity.id)
            .setData(activityDocumentData(for: activity)) { error in
                if let error {
                    print("Failed to save activity: \(error)")
                }
            }
    }

    private func deleteActivityFromFirebase(id: String) {
        guard let uid = currentUserID else { return }

        db.collection("users").document(uid)
            .collection("activities").document(id)
            .delete { error in
                if let error {
                    print("Failed to delete activity: \(error)")
                }
            }
    }

    private func loadCachedActivities(for userID: String?) {
        guard let data = UserDefaults.standard.data(forKey: activitiesKey(for: userID)),
              let decoded = try? JSONDecoder().decode([Activity].self, from: data) else {
            activities = []
            return
        }
        activities = decoded
    }

    private func cacheActivities(_ activities: [Activity], for userID: String?) {
        guard let data = try? JSONEncoder().encode(activities) else { return }
        UserDefaults.standard.set(data, forKey: activitiesKey(for: userID))
    }

    private func activityDocumentData(for activity: Activity) -> [String: Any] {
        var data: [String: Any] = [
            "id": activity.id,
            "name": activity.name,
            "completionDate": timestamp(fromISO: activity.completionDate),
            "uploadDate": timestamp(fromISO: activity.uploadDate),
            "distanceMiles": activity.distanceMiles,
            "durationSeconds": activity.durationSeconds,
            "avgPaceSecondsPerMile": activity.avgPaceSecondsPerMile,
            "category": activity.category.rawValue,
            "notes": activity.notes,
        ]
        data["linkedPlannedRunID"] = activity.linkedPlannedRunID ?? NSNull()
        return data
    }

    private func makeActivity(from document: QueryDocumentSnapshot) -> Activity? {
        let data = document.data()

        guard
            let completionDate = isoDateString(from: data["completionDate"]),
            let uploadDate = isoDateString(from: data["uploadDate"]) ?? isoDateString(from: data["completionDate"]),
            let categoryRawValue = data["category"] as? String,
            let category = RunCategory(rawValue: categoryRawValue)
        else {
            return nil
        }

        return Activity(
            id: (data["id"] as? String) ?? document.documentID,
            name: (data["name"] as? String) ?? "",
            completionDate: completionDate,
            uploadDate: uploadDate,
            distanceMiles: doubleValue(from: data["distanceMiles"]),
            durationSeconds: intValue(from: data["durationSeconds"]),
            category: category,
            notes: (data["notes"] as? String) ?? "",
            linkedPlannedRunID: data["linkedPlannedRunID"] as? String
        )
    }

    // MARK: - Week Plans

    func cachedWeekPlan(_ weekStart: String) -> [ScheduledRun] {
        guard let data = UserDefaults.standard.data(forKey: weekKey(weekStart, userID: currentUserID)),
              let runs = try? JSONDecoder().decode([ScheduledRun].self, from: data) else {
            return []
        }

        return runs
    }

    func loadWeekPlan(_ weekStart: String) async -> [ScheduledRun] {
        let cached = cachedWeekPlan(weekStart)
        guard let uid = currentUserID else { return cached }

        do {
            let document = try await db.collection("users").document(uid)
                .collection("weekPlans").document(weekStart)
                .getDocument()

            guard document.exists else {
                return cached
            }

            let runs = parseRuns(from: document.data()?["runs"])
            cacheWeekPlan(runs, weekStart: weekStart, userID: uid)
            return runs
        } catch {
            print("Failed to load week plan: \(error)")
            return cached
        }
    }

    func saveWeekPlan(_ runs: [ScheduledRun], weekStart: String) {
        cacheWeekPlan(runs, weekStart: weekStart, userID: currentUserID)
        saveWeekPlanToFirebase(runs, weekStart: weekStart)
    }

    func saveWeekPlanToFirebase(_ runs: [ScheduledRun], weekStart: String) {
        guard let uid = currentUserID else { return }

        let payload: [[String: Any]] = runs.map { run in
            [
                "id": run.id.uuidString,
                "type": run.type.rawValue,
                "day": run.day,
                "time": run.timeOfDay.rawValue,
                "distanceMiles": run.distanceMiles,
            ]
        }

        db.collection("users").document(uid)
            .collection("weekPlans").document(weekStart)
            .setData(
                [
                    "weekStartDate": timestamp(fromISO: weekStart),
                    "updatedAt": FieldValue.serverTimestamp(),
                    "runs": payload,
                ],
                merge: true
            ) { error in
                if let error {
                    print("Failed to save week plan: \(error)")
                }
            }
    }

    func loadWeekPlanFromFirebase(_ weekStart: String) async -> [ScheduledRun] {
        await loadWeekPlan(weekStart)
    }

    private func cacheWeekPlan(_ runs: [ScheduledRun], weekStart: String, userID: String?) {
        guard let data = try? JSONEncoder().encode(runs) else { return }
        UserDefaults.standard.set(data, forKey: weekKey(weekStart, userID: userID))
    }

    private func parseRuns(from rawValue: Any?) -> [ScheduledRun] {
        guard let runsData = rawValue as? [[String: Any]] else { return [] }

        return runsData.compactMap { dictionary in
            guard
                let idString = dictionary["id"] as? String,
                let id = UUID(uuidString: idString),
                let typeString = dictionary["type"] as? String,
                let type = RunType(rawValue: typeString),
                let day = dictionary["day"] as? Int,
                let timeString = (dictionary["time"] as? String) ?? (dictionary["timeOfDay"] as? String),
                let timeOfDay = TimeOfDay(rawValue: timeString)
            else {
                return nil
            }

            return ScheduledRun(
                id: id,
                type: type,
                day: day,
                timeOfDay: timeOfDay,
                distanceMiles: doubleValue(from: dictionary["distanceMiles"])
            )
        }
    }

    // MARK: - Computed Helpers

    func weekActivities(_ weekStart: String) -> [Activity] {
        guard let start = Self.isoToDate(weekStart) else { return [] }
        let end = start.addingTimeInterval(7 * 86400)
        return activities.filter {
            guard let date = Self.isoToDate($0.completionDate) else { return false }
            return date >= start && date < end
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

    func linkedPlannedRun(for activity: Activity) -> ScheduledRun? {
        guard
            let linkedPlannedRunID = activity.linkedPlannedRunID,
            let weekStart = Self.weekStart(forISODate: activity.completionDate)
        else {
            return nil
        }

        return cachedWeekPlan(weekStart).first { $0.id.uuidString == linkedPlannedRunID }
    }

    func historicalTrendComparison(for weekStart: String) -> HistoricalTrendComparison {
        let currentActivities = weekActivities(weekStart)
        let previousWeekStart = Self.shiftWeek(weekStart, by: -1)
        let previousActivities = weekActivities(previousWeekStart)

        let trailingWeeks = (1...4).map { offset in
            weekActivities(Self.shiftWeek(weekStart, by: -offset))
        }

        let trailingMilesTotal = trailingWeeks.reduce(0.0) { $0 + totalMiles($1) }
        let trailingRunsTotal = trailingWeeks.reduce(0) { $0 + $1.count }
        let trailingSecondsTotal = trailingWeeks.reduce(0) { partialResult, week in
            partialResult + week.reduce(0) { $0 + $1.durationSeconds }
        }
        let trailingWeekCount = Double(max(trailingWeeks.count, 1))

        return HistoricalTrendComparison(
            currentMiles: totalMiles(currentActivities),
            previousMiles: totalMiles(previousActivities),
            fourWeekAverageMiles: trailingMilesTotal / trailingWeekCount,
            currentRuns: currentActivities.count,
            previousRuns: previousActivities.count,
            fourWeekAverageRuns: Double(trailingRunsTotal) / trailingWeekCount,
            currentPaceSeconds: avgPaceSeconds(currentActivities),
            previousPaceSeconds: avgPaceSeconds(previousActivities),
            fourWeekAveragePaceSeconds: trailingMilesTotal > 0
                ? Int(round(Double(trailingSecondsTotal) / trailingMilesTotal))
                : 0
        )
    }

    func weeklyReview(weekStart: String, plannedRuns: [ScheduledRun]? = nil) -> WeeklyReview {
        let plannedRuns = plannedRuns ?? cachedWeekPlan(weekStart)
        let currentWeekActivities = weekActivities(weekStart)
        let matchedActivities = matchedActivitiesForPlan(plannedRuns: plannedRuns, activities: currentWeekActivities)
        let previousWeekStart = Self.shiftWeek(weekStart, by: -1)
        let previousPlannedRuns = cachedWeekPlan(previousWeekStart)
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
        let plannedRuns = cachedWeekPlan(weekStart)
        let weekActivities = weekActivities(weekStart)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")

        return (0..<7).map { dayIndex in
            let dayISO = Self.shiftWeek(weekStart, by: 0)
            let date = Self.isoToDate(dayISO)?.addingTimeInterval(Double(dayIndex) * 86400)
            let isoDate = date.map { formatter.string(from: $0) } ?? weekStart
            let dayActivities = weekActivities.filter { $0.completionDate == isoDate }

            return DailyMileagePoint(
                id: dayIndex,
                dayIndex: dayIndex,
                label: shortWeekdayLabel(for: dayIndex),
                plannedMiles: plannedRuns.filter { $0.day == dayIndex }.reduce(0) { $0 + $1.distanceMiles },
                actualMiles: totalMiles(dayActivities)
            )
        }
    }

    // MARK: - Firebase Sync

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
            let document = try await userStatsCollection()
                .document(weekStart)
                .getDocument()
            return try document.data(as: WeeklyStats.self)
        } catch {
            print("Failed to load weekly stats: \(error)")
            return nil
        }
    }

    func saveProfile(_ profile: UserProfile) {
        guard let uid = currentUserID else { return }
        self.profile = profile

        db.collection("users").document(uid).setData(
            [
                "fullName": profile.fullName,
                "email": profile.email,
                "weeklyMileageGoal": profile.weeklyMileageGoal,
                "weeklyRunGoal": profile.weeklyRunGoal,
                "allTimeMileGoal": profile.allTimeMileGoal,
            ],
            merge: true
        ) { error in
            if let error {
                print("Failed to save profile: \(error)")
            }
        }
    }

    func loadProfile() async -> UserProfile? {
        guard let uid = currentUserID else { return nil }

        do {
            let document = try await db.collection("users").document(uid).getDocument()
            guard let data = document.data() else { return nil }

            let loadedProfile = UserProfile(
                fullName: (data["fullName"] as? String) ?? (data["displayName"] as? String) ?? "",
                email: (data["email"] as? String) ?? "",
                weeklyMileageGoal: max(doubleValue(from: data["weeklyMileageGoal"]), UserProfile.defaultGoals.weeklyMileageGoal),
                weeklyRunGoal: max(intValue(from: data["weeklyRunGoal"]), UserProfile.defaultGoals.weeklyRunGoal),
                allTimeMileGoal: max(doubleValue(from: data["allTimeMileGoal"]), UserProfile.defaultGoals.allTimeMileGoal)
            )
            profile = loadedProfile
            return loadedProfile
        } catch {
            print("Failed to load profile: \(error)")
            return nil
        }
    }

    func updateGoals(weeklyMileageGoal: Double, weeklyRunGoal: Int, allTimeMileGoal: Double) {
        let nextProfile = UserProfile(
            fullName: profile.fullName.isEmpty ? (Auth.auth().currentUser?.displayName ?? "") : profile.fullName,
            email: profile.email.isEmpty ? (Auth.auth().currentUser?.email ?? "") : profile.email,
            weeklyMileageGoal: weeklyMileageGoal,
            weeklyRunGoal: weeklyRunGoal,
            allTimeMileGoal: allTimeMileGoal
        )
        saveProfile(nextProfile)
    }

    private func ensureUserDocument(for user: User) async {
        let userDocument = db.collection("users").document(user.uid)

        do {
            let snapshot = try await userDocument.getDocument()
            let baseFields: [String: Any] = [
                "displayName": user.displayName ?? "",
                "email": user.email ?? "",
                "profilePhotoUrl": user.photoURL?.absoluteString ?? "",
            ]

            if snapshot.exists {
                try await userDocument.setData(baseFields, merge: true)
            } else {
                try await userDocument.setData(baseFields)
            }
        } catch {
            print("Failed to ensure user document: \(error)")
        }
    }

    private func userStatsCollection() throws -> CollectionReference {
        guard let uid = currentUserID else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not logged in"])
        }

        return db.collection("users").document(uid).collection("weeklyStats")
    }

    // MARK: - Static Date Utilities

    static func currentWeekStart() -> String {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        let monday = calendar.date(from: components) ?? Date()
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
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }

    static func parseDuration(_ input: String) -> Int? {
        let parts = input.split(separator: ":", omittingEmptySubsequences: false).map { Int($0) }
        guard !parts.isEmpty, parts.allSatisfy({ $0 != nil }) else { return nil }
        let values = parts.compactMap { $0 }
        switch values.count {
        case 3:
            return values[0] * 3600 + values[1] * 60 + values[2]
        case 2:
            return values[0] * 60 + values[1]
        default:
            return nil
        }
    }

    static func weekStart(forISODate iso: String) -> String? {
        guard let date = isoToDate(iso) else { return nil }
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        guard let monday = calendar.date(from: components) else { return nil }
        return dateToISO(monday)
    }

    private static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()

    // MARK: - Private Helpers

    private func activitiesKey(for userID: String?) -> String {
        "tempo_activities_\(userID ?? "guest")"
    }

    private func weekKey(_ weekStart: String, userID: String?) -> String {
        "tempo_week_\(userID ?? "guest")_\(weekStart)"
    }

    private func timestamp(fromISO iso: String) -> Timestamp {
        Timestamp(date: Self.isoToDate(iso) ?? Date())
    }

    private func isoDateString(from value: Any?) -> String? {
        if let timestamp = value as? Timestamp {
            return Self.dateToISO(timestamp.dateValue())
        }

        if let date = value as? Date {
            return Self.dateToISO(date)
        }

        if let iso = value as? String {
            if iso.count >= 10 {
                return String(iso.prefix(10))
            }
            return iso
        }

        return nil
    }

    private func doubleValue(from value: Any?) -> Double {
        switch value {
        case let double as Double:
            double
        case let int as Int:
            Double(int)
        case let number as NSNumber:
            number.doubleValue
        default:
            0
        }
    }

    private func intValue(from value: Any?) -> Int {
        switch value {
        case let int as Int:
            int
        case let double as Double:
            Int(double)
        case let number as NSNumber:
            number.intValue
        default:
            0
        }
    }

    private func matchedActivitiesForPlan(plannedRuns: [ScheduledRun], activities: [Activity]) -> [Activity] {
        var remaining = activities.sorted { lhs, rhs in
            lhs.completionDate < rhs.completionDate
        }
        var matches: [Activity] = []

        for run in plannedRuns {
            let explicitIndex = remaining.firstIndex { activity in
                activity.linkedPlannedRunID == run.id.uuidString
            }
            let fallbackIndex = remaining.firstIndex { activity in
                activity.linkedPlannedRunID == nil && activity.category.matches(run.type)
            }

            guard let index = explicitIndex ?? fallbackIndex else { continue }
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
