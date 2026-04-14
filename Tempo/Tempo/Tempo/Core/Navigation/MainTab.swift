import SwiftUI

enum MainTab: Hashable {
    case home, planner, record, activity, profile

    var title: String {
        switch self {
        case .home:     "Home"
        case .planner:  "Planner"
        case .record:   "Record"
        case .activity: "Activity"
        case .profile:  "Profile"
        }
    }

    var symbolName: String {
        switch self {
        case .home:     "house.fill"
        case .planner:  "calendar"
        case .record:   "plus.circle.fill"
        case .activity: "chart.bar.fill"
        case .profile:  "person.fill"
        }
    }
}
