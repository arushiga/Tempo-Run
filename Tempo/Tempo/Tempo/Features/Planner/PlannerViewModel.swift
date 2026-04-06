import Foundation
import Observation

@Observable
final class PlannerViewModel {
    let dayLabels = ["M", "T", "W", "R", "F", "S", "S"]
    var scheduledRuns: [ScheduledRun] = [
        ScheduledRun(type: .easy, day: 0, timeOfDay: .am),
        ScheduledRun(type: .tempo, day: 1, timeOfDay: .pm),
    ]

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
        guard let movedIndex = scheduledRuns.firstIndex(where: { $0.id == id }) else {
            return
        }

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

    var totalRuns: Int {
        scheduledRuns.count
    }

    var relativeLoad: Int {
        43 - (7 - totalRuns) * 5
    }

    var trainingIntensity: Int {
        15 + count(for: .tempo) * 5 + count(for: .race) * 10
    }
}
