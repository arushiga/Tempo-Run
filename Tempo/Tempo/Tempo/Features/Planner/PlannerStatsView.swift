import SwiftUI

struct PlannerStatsView: View {
    let viewModel: PlannerViewModel

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("This Week")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                HStack(spacing: 12) {
                    PlannerStatTile(title: "Easy", value: viewModel.count(for: .easy), color: RunType.easy.color)
                    PlannerStatTile(title: "Tempo", value: viewModel.count(for: .tempo), color: RunType.tempo.color)
                    PlannerStatTile(title: "Race", value: viewModel.count(for: .race), color: RunType.race.color)
                    PlannerStatTile(title: "Long", value: viewModel.count(for: .longRun), color: RunType.longRun.color)
                }

                PlannerMetricRow(
                    title: "Relative Load",
                    value: viewModel.relativeLoad,
                    tint: viewModel.relativeLoad > 30 ? TempoColor.warmAccent : TempoColor.secondary
                )

                PlannerMetricRow(
                    title: "Training Intensity",
                    value: viewModel.trainingIntensity,
                    tint: viewModel.trainingIntensity > 20 ? TempoColor.warmAccent : TempoColor.secondary
                )
            }
        }
    }
}

private struct PlannerStatTile: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(TempoColor.slate)

            Text("\(value)")
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct PlannerMetricRow: View {
    let title: String
    let value: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(TempoColor.ink)

                Spacer()

                Text("\(value > 0 ? "+" : "")\(value)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(tint)
            }

            ProgressView(value: min(Double(abs(value)) / 50, 1))
                .tint(tint)
        }
    }
}
