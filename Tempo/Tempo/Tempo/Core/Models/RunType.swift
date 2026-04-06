import SwiftUI

enum RunType: String, Codable, CaseIterable, Identifiable {
    case easy = "Easy"
    case tempo = "Tempo"
    case race = "Race"
    case longRun = "Long Run"

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .easy:
            "Easy"
        case .tempo:
            "Tempo"
        case .race:
            "Race"
        case .longRun:
            "Long"
        }
    }

    var symbolName: String {
        switch self {
        case .easy:
            "figure.run"
        case .tempo:
            "bolt.heart.fill"
        case .race:
            "flag.checkered"
        case .longRun:
            "road.lanes"
        }
    }

    var color: Color {
        switch self {
        case .easy:
            Color(red: 0.05, green: 0.65, blue: 0.91)
        case .tempo:
            Color(red: 0.96, green: 0.45, blue: 0.09)
        case .race:
            Color(red: 0.66, green: 0.33, blue: 0.97)
        case .longRun:
            Color(red: 0.06, green: 0.72, blue: 0.51)
        }
    }
}
