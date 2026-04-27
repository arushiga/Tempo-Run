import SwiftUI

struct RunTypePickerView: View {
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 8) {
                    Text("Run Types")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(TempoColor.ink)
                    Image(systemName: "hand.draw")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(TempoColor.primary)
                }

                HStack(spacing: 16) {
                    ForEach(RunType.allCases) { runType in
                        PlannerRunTypeToken(runType: runType)
                    }
                }

                Text("Drag and drop — long hold the icons")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TempoColor.slate)
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
                .fill(TempoColor.surfaceMuted)
                .frame(width: 58, height: 58)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(TempoColor.lineStrong.opacity(0.95), lineWidth: 1.5)
                }
                .overlay {
                    Image(systemName: runType.symbolName)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(runType.color)
                }
                .shadow(color: TempoColor.ink.opacity(0.04), radius: 6, y: 2)
                .scaleEffect(isDragging ? 0.92 : 1)
                .opacity(isDragging ? 0.65 : 1)

            Text(runType.shortLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(TempoColor.muted)
        }
        .draggable(PlannerDragItem.runType(runType)) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TempoColor.surface)
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
