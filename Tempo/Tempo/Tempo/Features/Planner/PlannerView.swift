import SwiftUI

struct PlannerView: View {
    @State private var viewModel = PlannerViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                plannerHeader
                PlannerGridView(viewModel: viewModel)
                RunTypePickerView()
                PlannerStatsView(viewModel: viewModel)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Planner")
    }

    private var plannerHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Planner")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Drag and drop to schedule your runs.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.88))

            Text("Each cell accepts one workout. Drop to replace, tap a scheduled cell to remove.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(TempoGradient.hero)
        )
        .shadow(color: TempoColor.primary.opacity(0.24), radius: 18, y: 10)
    }
}

#Preview {
    NavigationStack {
        PlannerView()
    }
}
