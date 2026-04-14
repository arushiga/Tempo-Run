import Foundation
import Observation

@Observable
final class PlannerViewModel {
    let dayLabels = ["M", "T", "W", "R", "F", "S", "S"]

    // MARK: - Week state
    var currentWeekStart: String = AppDataStore.currentWeekStart()
    var expandedDays: Set<Int> = []

    // MARK: - Runs (pre-populated defaults for first launch)
    var scheduledRuns: [ScheduledRun] = [
        ScheduledRun(type: .easy, day: 0, timeOfDay: .am),
        ScheduledRun(type: .tempo, day: 1, timeOfDay: .pm),
    ]

    // MARK: - Drag-and-drop (unchanged)

    func scheduledRun(for day: Int, timeOfDay: TimeOfDay) -> ScheduledRun? {
        scheduledRuns.first { $0.day == day && $0.timeOfDay == timeOfDay }
    }

    func addOrReplaceRun(type: RunType, day: Int, timeOfDay: TimeOfDay) {
        if let existingIndex = scheduledRuns.firstIndex(where: { $0.day == day && $0.timeOfDay == timeOfDay }) {
            scheduledRuns[existingIndex] = ScheduledRun(type: type, day: day, timeOfDay: timeOfDay)
        } else {
            scheduledRuns.append(ScheduledRun(type: type, day: day, timeOfDay: timeOfDay))
        }
    }

    func moveRun(id: UUID, to day: Int, timeOfDay: TimeOfDay) {
        guard let movedIndex = scheduledRuns.firstIndex(where: { $0.id == id }) else { return }

        let conflictingRunID = scheduledRuns.first {
            $0.day == day && $0.timeOfDay == timeOfDay && $0.id != id
        }?.id

        scheduledRuns[movedIndex].day = day
        scheduledRuns[movedIndex].timeOfDay = timeOfDay

        if let conflictingRunID {
            scheduledRuns.removeAll { $0.id == conflictingRunID }
        }
    }

    func removeRun(id: UUID) {
        scheduledRuns.removeAll { $0.id == id }
    }

    func count(for runType: RunType) -> Int {
        scheduledRuns.filter { $0.type == runType }.count
    }

    var totalRuns: Int { scheduledRuns.count }

    var relativeLoad: Int { 43 - (7 - totalRuns) * 5 }

    var trainingIntensity: Int { 15 + count(for: .tempo) * 5 + count(for: .race) * 10 }

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
        if expandedDays.contains(day) {
            expandedDays.remove(day)
        } else {
            expandedDays.insert(day)
        }
    }

    func setDistance(_ miles: Double, for runID: UUID) {
        guard let idx = scheduledRuns.firstIndex(where: { $0.id == runID }) else { return }
        scheduledRuns[idx].distanceMiles = miles
    }

    func runsForDay(_ day: Int) -> [ScheduledRun] {
        scheduledRuns.filter { $0.day == day }
    }

    // MARK: - Week display

    var weekDisplayString: String {
        AppDataStore.formatDisplayDate(currentWeekStart)
    }
}
