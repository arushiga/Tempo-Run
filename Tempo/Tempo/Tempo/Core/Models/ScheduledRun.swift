import Foundation

struct ScheduledRun: Identifiable, Codable, Hashable {
    let id: UUID
    var type: RunType
    var day: Int
    var timeOfDay: TimeOfDay

    init(id: UUID = UUID(), type: RunType, day: Int, timeOfDay: TimeOfDay) {
        self.id = id
        self.type = type
        self.day = day
        self.timeOfDay = timeOfDay
    }
}

enum TimeOfDay: String, Codable, CaseIterable, Hashable, Identifiable {
    case am = "AM"
    case pm = "PM"

    var id: String { rawValue }
}
