import SwiftUI

struct RunTypePickerView: View {
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                Text("Run Types")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                HStack(spacing: 16) {
                    ForEach(RunType.allCases) { runType in
                        PlannerRunTypeToken(runType: runType)
                    }
                }
            }
        }
    }
}

private struct PlannerRunTypeToken: View {
    let runType: RunType
    @State private var isDragging = false

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(runType.color.opacity(0.12))
                .frame(width: 58, height: 58)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(runType.color, lineWidth: 2)
                }
                .overlay {
                    Image(systemName: runType.symbolName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(runType.color)
                }
                .scaleEffect(isDragging ? 0.92 : 1)
                .opacity(isDragging ? 0.65 : 1)

            Text(runType.shortLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(TempoColor.slate)
        }
        .draggable(PlannerDragItem.runType(runType)) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(runType.color.opacity(0.15))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: runType.symbolName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(runType.color)
                        .onAppear { isDragging = true }
                        .onDisappear { isDragging = false }
                }
        }
    }
}
