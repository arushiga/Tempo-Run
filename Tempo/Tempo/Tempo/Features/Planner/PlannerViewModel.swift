import Foundation
import Observation

@Observable
final class PlannerViewModel {
    let dayLabels = ["M", "T", "W", "R", "F", "S", "S"]

    var currentWeekStart: String = AppDataStore.currentWeekStart()
    var expandedDays: Set<Int> = []

    var scheduledRuns: [ScheduledRun] = [
        ScheduledRun(type: .easy, day: 0, timeOfDay: .am),
        ScheduledRun(type: .tempo, day: 1, timeOfDay: .pm),
    ]

    // MARK: - Drag-and-drop (unchanged)

    func scheduledRun(for day: Int, timeOfDay: TimeOfDay) -> ScheduledRun? {
        scheduledRuns.first { $0.day == day && $0.timeOfDay == timeOfDay }
    }

    func addOrReplaceRun(type: RunType, day: Int, timeOfDay: TimeOfDay) {
        if let idx = scheduledRuns.firstIndex(where: { $0.day == day && $0.timeOfDay == timeOfDay }) {
            scheduledRuns[idx] = ScheduledRun(type: type, day: day, timeOfDay: timeOfDay)
        } else {
            scheduledRuns.append(ScheduledRun(type: type, day: day, timeOfDay: timeOfDay))
        }
    }

    func moveRun(id: UUID, to day: Int, timeOfDay: TimeOfDay) {
        guard let movedIdx = scheduledRuns.firstIndex(where: { $0.id == id }) else { return }
        let conflictID = scheduledRuns.first { $0.day == day && $0.timeOfDay == timeOfDay && $0.id != id }?.id
        scheduledRuns[movedIdx].day = day
        scheduledRuns[movedIdx].timeOfDay = timeOfDay
        if let conflictID { scheduledRuns.removeAll { $0.id == conflictID } }
    }

    func removeRun(id: UUID) {
        scheduledRuns.removeAll { $0.id == id }
    }

    func count(for runType: RunType) -> Int {
        scheduledRuns.filter { $0.type == runType }.count
    }

    var totalRuns: Int { scheduledRuns.count }
    var relativeLoad: Int { max(0, 43 - (7 - totalRuns) * 5) }
    var trainingIntensity: Int { 15 + count(for: .tempo) * 5 + count(for: .race) * 10 }
    var plannedMiles: Double { scheduledRuns.reduce(0) { $0 + $1.distanceMiles } }

    // MARK: - Week navigation

    func goToPrevWeek(store: AppDataStore) {
        store.saveWeekPlan(scheduledRuns, weekStart: currentWeekStart)
        currentWeekStart = AppDataStore.shiftWeek(currentWeekStart, by: -1)
        let saved = store.loadWeekPlan(currentWeekStart)
        scheduledRuns = saved.isEmpty ? [] : saved
        expandedDays = []
    }

    func goToNextWeek(store: AppDataStore) {
        store.saveWeekPlan(scheduledRuns, weekStart: currentWeekStart)
        currentWeekStart = AppDataStore.shiftWeek(currentWeekStart, by: 1)
        let saved = store.loadWeekPlan(currentWeekStart)
        scheduledRuns = saved.isEmpty ? [] : saved
        expandedDays = []
    }

    func saveCurrent(store: AppDataStore) {
        store.saveWeekPlan(scheduledRuns, weekStart: currentWeekStart)
    }

    // MARK: - Distance sliders

    func toggleDay(_ day: Int) {
        if expandedDays.contains(day) { expandedDays.remove(day) }
        else { expandedDays.insert(day) }
    }

    func setDistance(_ miles: Double, for runID: UUID) {
        guard let idx = scheduledRuns.firstIndex(where: { $0.id == runID }) else { return }
        scheduledRuns[idx].distanceMiles = miles
    }

    func runsForDay(_ day: Int) -> [ScheduledRun] {
        scheduledRuns.filter { $0.day == day }
    }

    var weekDisplayString: String {
        AppDataStore.formatDisplayDate(currentWeekStart)
    }
}
