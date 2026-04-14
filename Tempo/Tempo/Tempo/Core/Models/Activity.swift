import SwiftUI

struct Activity: Identifiable, Codable {
    let id: String
    var name: String
    var completionDate: String   // "YYYY-MM-DD"
    var uploadDate: String
    var distanceMiles: Double
    var durationSeconds: Int
    var avgPaceSecondsPerMile: Int
    var category: RunCategory

    init(
        id: String = UUID().uuidString,
        name: String,
        completionDate: String,
        uploadDate: String,
        distanceMiles: Double,
        durationSeconds: Int,
        category: RunCategory
    ) {
        self.id = id
        self.name = name
        self.completionDate = completionDate
        self.uploadDate = uploadDate
        self.distanceMiles = distanceMiles
        self.durationSeconds = durationSeconds
        self.avgPaceSecondsPerMile = distanceMiles > 0
            ? Int(Double(durationSeconds) / distanceMiles)
            : 0
        self.category = category
    }
}

enum RunCategory: String, Codable, CaseIterable {
    case easy, tempo, long, race

    var label: String {
        switch self {
        case .easy:  "Easy"
        case .tempo: "Tempo"
        case .long:  "Long Run"
        case .race:  "Race"
        }
    }

    var emoji: String {
        switch self {
        case .easy:  "🟢"
        case .tempo: "🟠"
        case .long:  "🔵"
        case .race:  "🟣"
        }
    }

    var color: Color {
        switch self {
        case .easy:  Color(red: 0.06, green: 0.72, blue: 0.51)
        case .tempo: Color(red: 0.96, green: 0.45, blue: 0.09)
        case .long:  Color(red: 0.05, green: 0.65, blue: 0.91)
        case .race:  Color(red: 0.66, green: 0.33, blue: 0.97)
        }
    }
}
