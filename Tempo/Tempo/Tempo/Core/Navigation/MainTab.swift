import SwiftUI

enum MainTab: Hashable {
    case home
    case planner
    case profile

    var title: String {
        switch self {
        case .home:
            "Home"
        case .planner:
            "Planner"
        case .profile:
            "Profile"
        }
    }

    var symbolName: String {
        switch self {
        case .home:
            "house"
        case .planner:
            "calendar"
        case .profile:
            "person"
        }
    }
}
