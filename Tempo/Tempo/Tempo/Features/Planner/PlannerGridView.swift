import SwiftUI

struct PlannerGridView: View {
    let viewModel: PlannerViewModel

    var body: some View {
        VStack(spacing: 18) {
            dayHeaderRow
            ForEach(TimeOfDay.allCases) { timeOfDay in
                HStack(spacing: 3) {
                    Text(timeOfDay.rawValue)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(TempoColor.slate)
                        .frame(width: 16, alignment: .leading)
                    ForEach(Array(viewModel.dayLabels.enumerated()), id: \.offset) { index, _ in
                        PlannerCellView(day: index, timeOfDay: timeOfDay, viewModel: viewModel)
                    }
                }
            }
            distanceSlidersSection
            Text("Tip: drag from the run types below or drag an existing workout to move it.")
                .font(.caption).foregroundStyle(TempoColor.slate)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(TempoColor.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TempoColor.lineStrong.opacity(0.75), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.045), radius: 12, y: 3)
    }

    private var dayHeaderRow: some View {
        HStack(spacing: 3) {
            Spacer().frame(width: 16)
            ForEach(Array(viewModel.dayLabels.enumerated()), id: \.offset) { index, label in
                Button { viewModel.toggleDay(index) } label: {
                    VStack(spacing: 2) {
                        Text(label)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(TempoColor.ink)
                        Image(systemName: viewModel.expandedDays.contains(index) ? "chevron.up" : "chevron.down")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(!viewModel.runsForDay(index).isEmpty ? TempoColor.primary : Color.clear)
                            .frame(height: 8)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var distanceSlidersSection: some View {
        ForEach(Array(viewModel.dayLabels.enumerated()), id: \.offset) { dayIndex, label in
            let runs = viewModel.runsForDay(dayIndex)
            if viewModel.expandedDays.contains(dayIndex) && !runs.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(label) — Planned Distance")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(TempoColor.slate)
                    ForEach(runs) { run in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: run.type.symbolName).foregroundStyle(run.type.color).font(.caption)
                                Text(run.type.shortLabel).font(.caption).foregroundStyle(TempoColor.ink)
                                Spacer()
                                MileageTextField(run: run, viewModel: viewModel)
                                    .frame(width: 82)
                            }
                            Slider(
                                value: Binding(
                                    get: { run.distanceMiles },
                                    set: { viewModel.setDistance($0, for: run.id) }
                                ),
                                in: 0...26.2, step: 0.1
                            )
                            .tint(run.type.color)
                        }
                        .padding(12)
                        .background(TempoColor.surfaceMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(TempoColor.line, lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 4)
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
        VStack(spacing: 4) {
            if let scheduledRun {
                Image(systemName: scheduledRun.type.symbolName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(scheduledRun.type.color)
                    .frame(height: 18)
                    .draggable(PlannerDragItem.scheduledRun(scheduledRun)) {
                        PlannerDragPreview(runType: scheduledRun.type)
                    }
                MileageTextField(run: scheduledRun, viewModel: viewModel)
                    .frame(height: 20)
            } else {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isTargeted ? TempoColor.primary : TempoColor.muted)
                    .frame(height: 18)
                Text("mi")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(TempoColor.muted.opacity(0.7))
                    .frame(height: 20)
            }
        }
        .padding(.horizontal, 3)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cellBackground(for: scheduledRun))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(cellBorder(for: scheduledRun), lineWidth: isTargeted ? 2 : 1)
        )
        .scaleEffect(isTargeted ? 1.08 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isTargeted)
        .dropDestination(for: PlannerDragItem.self) { items, _ in
            guard let item = items.first else { return false }
            switch item {
            case .runType(let t):        viewModel.addOrReplaceRun(type: t, day: day, timeOfDay: timeOfDay)
            case .scheduledRun(let run): viewModel.moveRun(id: run.id, to: day, timeOfDay: timeOfDay)
            }
            return true
        } isTargeted: { isTargeted = $0 }
    }

    private func cellBackground(for run: ScheduledRun?) -> Color {
        if let run { return run.type.color.opacity(0.08) }
        return isTargeted ? TempoColor.primary.opacity(0.08) : TempoColor.surfaceMuted
    }

    private func cellBorder(for run: ScheduledRun?) -> Color {
        if isTargeted { return TempoColor.primary }
        if let run { return run.type.color.opacity(0.5) }
        return TempoColor.lineStrong
    }
}

private struct MileageTextField: View {
    let run: ScheduledRun
    let viewModel: PlannerViewModel

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("0.0", text: $text)
            .font(.system(size: 11, weight: .bold))
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 0)
            .padding(.vertical, 3)
            .background(.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(isFocused ? run.type.color : TempoColor.line, lineWidth: 1)
            )
            .onAppear { syncTextFromRun() }
            .onChange(of: run.distanceMiles) { _, _ in
                if !isFocused { syncTextFromRun() }
            }
            .onChange(of: isFocused) { _, focused in
                if focused {
                    text = run.distanceMiles == 0 ? "" : formatted(run.distanceMiles)
                } else {
                    commit()
                }
            }
            .onSubmit { commit() }
    }

    private func syncTextFromRun() {
        text = run.distanceMiles == 0 ? "0.0" : formatted(run.distanceMiles)
    }

    private func commit() {
        let normalized = text
            .replacingOccurrences(of: "mi", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let value = max(0, min(Double(normalized) ?? 0, 26.2))
        viewModel.setDistance(value, for: run.id)
        text = formatted(value)
    }

    private func formatted(_ value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
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
