import Foundation

struct ScheduledRun: Identifiable, Codable, Hashable {
    let id: UUID
    var type: RunType
    var day: Int
    var timeOfDay: TimeOfDay
    var distanceMiles: Double = 0

    init(id: UUID = UUID(), type: RunType, day: Int, timeOfDay: TimeOfDay, distanceMiles: Double = 0) {
        self.id = id
        self.type = type
        self.day = day
        self.timeOfDay = timeOfDay
        self.distanceMiles = distanceMiles
    }
}

enum TimeOfDay: String, Codable, CaseIterable, Hashable, Identifiable {
    case am = "AM"
    case pm = "PM"

    var id: String { rawValue }
}
