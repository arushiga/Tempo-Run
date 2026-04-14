import SwiftUI
import Charts

struct PlannerStatsView: View {
    let viewModel: PlannerViewModel

    @Environment(AppDataStore.self) private var store
    @State private var activeExplanation: MetricExplanation?

    private var review: WeeklyReview {
        store.weeklyReview(weekStart: viewModel.currentWeekStart, plannedRuns: viewModel.scheduledRuns)
    }

    private var mileagePoints: [DailyMileagePoint] {
        store.dailyMileagePoints(weekStart: viewModel.currentWeekStart)
    }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 26) {
                Text("This Week")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                HStack(spacing: 12) {
                    PlannerStatTile(title: "Easy", value: viewModel.count(for: .easy), color: RunType.easy.color)
                    PlannerStatTile(title: "Tempo", value: viewModel.count(for: .tempo), color: RunType.tempo.color)
                    PlannerStatTile(title: "Race", value: viewModel.count(for: .race), color: RunType.race.color)
                    PlannerStatTile(title: "Long", value: viewModel.count(for: .longRun), color: RunType.longRun.color)
                }

                WeeklyCompletionCard(review: review)

                PlannerMetricRow(
                    title: "Relative Load",
                    value: review.plannedRelativeLoad,
                    comparisonValue: review.actualRelativeLoad,
                    tint: relativeLoadTint(review.plannedRelativeLoad),
                    explanationAction: { activeExplanation = .relativeLoad }
                )

                PlannerMetricRow(
                    title: "Training Intensity",
                    value: review.plannedIntensity,
                    comparisonValue: review.actualIntensity,
                    tint: TempoColor.secondary,
                    explanationAction: { activeExplanation = .trainingIntensity }
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Planned vs Actual Mileage")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(TempoColor.ink)

                    Chart(mileagePoints) { point in
                        BarMark(
                            x: .value("Day", point.label),
                            y: .value("Planned", point.plannedMiles)
                        )
                        .foregroundStyle(TempoColor.primary.opacity(0.35))
                        .position(by: .value("Series", "Planned"))

                        BarMark(
                            x: .value("Day", point.label),
                            y: .value("Actual", point.actualMiles)
                        )
                        .foregroundStyle(TempoColor.secondary)
                        .position(by: .value("Series", "Actual"))
                    }
                    .frame(height: 180)
                }
                .padding(18)
                .background(.white.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        }
        .alert(activeExplanation?.title ?? "", isPresented: Binding(
            get: { activeExplanation != nil },
            set: { if !$0 { activeExplanation = nil } }
        )) {
            Button("Done", role: .cancel) {}
        } message: {
            Text(activeExplanation?.message ?? "")
        }
    }

    private func relativeLoadTint(_ value: Int) -> Color {
        switch value {
        case ..<50:
            TempoColor.slate
        case ..<85:
            TempoColor.accent
        case 90...110:
            TempoColor.secondary
        case 111...120:
            TempoColor.warmAccent
        default:
            Color.red
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

private struct WeeklyCompletionCard: View {
    let review: WeeklyReview

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Week Overview")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)
                Spacer()
                Text("\(Int(review.completionFraction * 100))% complete")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(TempoColor.primary)
            }

            GoalProgressRow(
                label: "Training Progress",
                current: Double(review.completedPlannedRunCount),
                goal: Double(max(review.plannedRunCount, 1)),
                unit: "runs",
                color: TempoColor.primary
            )

            HStack(spacing: 16) {
                completionMetric(title: "Planned", value: String(format: "%.1f mi", review.plannedMiles))
                completionMetric(title: "Completed", value: String(format: "%.1f mi", review.actualMiles))
            }
        }
        .padding(18)
        .background(TempoColor.primary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func completionMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(TempoColor.slate)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(TempoColor.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PlannerMetricRow: View {
    let title: String
    let value: Int
    let comparisonValue: Int
    let tint: Color
    let explanationAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(TempoColor.ink)

                    Button(action: explanationAction) {
                        Image(systemName: "info.circle")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(TempoColor.primary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Plan \(formatted(value))")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(tint)
                    Text("Actual \(formatted(comparisonValue))")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(TempoColor.slate)
                }
            }

            ProgressView(value: progressValue)
                .tint(tint)
        }
        .padding(16)
        .background(.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func formatted(_ value: Int) -> String {
        title == "Relative Load" ? "\(value)%" : "\(value)"
    }

    private var progressValue: Double {
        if title == "Relative Load" {
            return min(Double(value) / 150, 1)
        }
        return min(Double(abs(value)) / 220, 1)
    }
}

private enum MetricExplanation {
    case relativeLoad
    case trainingIntensity

    var title: String {
        switch self {
        case .relativeLoad:
            "Relative Load"
        case .trainingIntensity:
            "Training Intensity"
        }
    }

    var message: String {
        switch self {
        case .relativeLoad:
            "Relative load compares this week's weighted training load to last week's load: (this week / last week) × 100. Around 90–110% is steady, 110–120% is progressive overload, and above 120% suggests too much too soon."
        case .trainingIntensity:
            "Training intensity uses a weighted distance score. Each planned mile is multiplied by a workout factor: easy 1.0, long 1.15, tempo 1.3, and race 1.55. The score also includes a small volume bonus so harder, longer weeks rank higher."
        }
    }
}
