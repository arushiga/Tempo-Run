import SwiftUI

struct PlannerPrototypeView: View {
    private let plannerItems = [
        ("Drag and drop grid", "Build from the web planner interaction"),
        ("One workout per cell", "Replace existing workout on drop"),
        ("Intensity visuals", "Map workout type to icon and color"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Planner")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("This tab is the native placeholder for the drag-and-drop planner prototype.")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.88))
                    }
                    .padding(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(TempoGradient.hero)
                    )
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Implementation Targets")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(TempoColor.ink)

                        ForEach(plannerItems, id: \.0) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.0)
                                    .font(.headline)
                                    .foregroundStyle(TempoColor.ink)

                                Text(item.1)
                                    .font(.subheadline)
                                    .foregroundStyle(TempoColor.slate)
                            }
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Prototype Notes")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(TempoColor.ink)

                        Text("Next step: port the calendar grid and run-type picker from the React prototype into SwiftUI models and draggable cells.")
                            .foregroundStyle(TempoColor.slate)

                        Text("For A5, this screen only needs to prove interaction feasibility, not full planner persistence.")
                            .foregroundStyle(TempoColor.slate)
                    }
                }
            }
            .padding(20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Planner")
    }
}

#Preview {
    NavigationStack {
        PlannerPrototypeView()
    }
}
