import SwiftUI

struct PlannerGridView: View {
    let viewModel: PlannerViewModel

    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                dayHeaderRow

                VStack(spacing: 16) {
                    ForEach(TimeOfDay.allCases) { timeOfDay in
                        HStack(spacing: 6) {
                            Text(timeOfDay.rawValue)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(TempoColor.slate)
                                .frame(width: 32, alignment: .leading)

                            ForEach(Array(viewModel.dayLabels.enumerated()), id: \.offset) { index, _ in
                                PlannerCellView(
                                    day: index,
                                    timeOfDay: timeOfDay,
                                    viewModel: viewModel
                                )
                            }
                        }
                    }
                }

                Text("Tip: drag from the run types below or drag an existing workout to move it.")
                    .font(.caption)
                    .foregroundStyle(TempoColor.slate)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var dayHeaderRow: some View {
        HStack(spacing: 6) {
            Spacer()
                .frame(width: 32)

            ForEach(Array(viewModel.dayLabels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(TempoColor.ink)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct PlannerCellView: View {
    let day: Int
    let timeOfDay: TimeOfDay
    let viewModel: PlannerViewModel

    @State private var isTargeted = false

    var body: some View {
        let scheduledRun = viewModel.scheduledRun(for: day, timeOfDay: timeOfDay)

        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cellBackground(for: scheduledRun))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(cellBorder(for: scheduledRun), lineWidth: isTargeted ? 3 : 2)
                )

            if let scheduledRun {
                Image(systemName: scheduledRun.type.symbolName)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(scheduledRun.type.color)
                    .draggable(PlannerDragItem.scheduledRun(scheduledRun)) {
                        PlannerDragPreview(runType: scheduledRun.type)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .scaleEffect(isTargeted ? 1.08 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isTargeted)
        .dropDestination(for: PlannerDragItem.self) { items, _ in
            guard let item = items.first else {
                return false
            }

            switch item {
            case .runType(let runType):
                viewModel.addOrReplaceRun(type: runType, day: day, timeOfDay: timeOfDay)
            case .scheduledRun(let scheduledRun):
                viewModel.moveRun(id: scheduledRun.id, to: day, timeOfDay: timeOfDay)
            }
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
        .onTapGesture {
            if let scheduledRun {
                viewModel.removeRun(id: scheduledRun.id)
            }
        }
    }

    private func cellBackground(for scheduledRun: ScheduledRun?) -> Color {
        if let scheduledRun {
            return scheduledRun.type.color.opacity(0.12)
        }

        if isTargeted {
            return TempoColor.primary.opacity(0.1)
        }

        return .white.opacity(0.9)
    }

    private func cellBorder(for scheduledRun: ScheduledRun?) -> Color {
        if isTargeted {
            return TempoColor.primary
        }

        if let scheduledRun {
            return scheduledRun.type.color
        }

        return Color.gray.opacity(0.2)
    }
}

private struct PlannerDragPreview: View {
    let runType: RunType

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(runType.color.opacity(0.15))
            .frame(width: 56, height: 56)
            .overlay {
                Image(systemName: runType.symbolName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(runType.color)
            }
    }
}
