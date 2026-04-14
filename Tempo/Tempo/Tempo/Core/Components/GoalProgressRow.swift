import SwiftUI

struct GoalProgressRow: View {
    let label: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color

    private var fraction: Double { min(current / goal, 1.0) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(TempoColor.ink)
                Spacer()
                Text(progressLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
            }
            ProgressView(value: fraction)
                .tint(color)
        }
    }

    private var progressLabel: String {
        if goal == goal.rounded() {
            return String(format: "%.0f / %.0f %@", current, goal, unit)
        }
        return String(format: "%.1f / %.0f %@", current, goal, unit)
    }
}
