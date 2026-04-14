import Foundation

struct WeekPlan: Codable, Hashable {
    var weekStartDate: String
    var runs: [ScheduledRun]

    init(weekStartDate: String, runs: [ScheduledRun] = []) {
        self.weekStartDate = weekStartDate
        self.runs = runs
    }
}
