import SwiftUI

struct GoalProgressRow: View {
    let label: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color

    private var fraction: Double { min(current / goal, 1.0) }
    private var usesWholeNumbers: Bool {
        current.rounded() == current && goal.rounded() == goal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label).font(.subheadline).foregroundStyle(TempoColor.ink)
                Spacer()
                Text(progressText)
                    .font(.subheadline.weight(.semibold)).foregroundStyle(color)
            }
            ProgressView(value: fraction).tint(color)
        }
    }

    private var progressText: String {
        if usesWholeNumbers {
            "\(Int(current)) / \(Int(goal)) \(unit)"
        } else {
            String(format: "%.1f / %.0f %@", current, goal, unit)
        }
    }
}
