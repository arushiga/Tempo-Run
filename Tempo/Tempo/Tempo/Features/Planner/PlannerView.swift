import SwiftUI

struct PlannerView: View {
    @State private var viewModel = PlannerViewModel()
    @Environment(AppDataStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                plannerHeader
                weekNavBar
                PlannerGridView(viewModel: viewModel)
                RunTypePickerView()
                PlannerStatsView(viewModel: viewModel)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Planner")
        .task {
            let runs = await store.loadWeekPlanFromFirebase(viewModel.currentWeekStart)
            if !runs.isEmpty {
                viewModel.scheduledRuns = runs
            }
        }
        .onChange(of: viewModel.scheduledRuns) { _, _ in
            viewModel.saveCurrent(store: store)
        }
        .onDisappear { viewModel.saveCurrent(store: store) }
    }

    private var plannerHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Planner")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(TempoColor.ink)
            Text("Drag and drop to schedule your runs.")
                .font(.headline)
                .foregroundStyle(TempoColor.slate)
            Text("Each cell accepts one workout. Drop to replace, tap a scheduled cell to remove.")
                .font(.subheadline)
                .foregroundStyle(TempoColor.muted)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(TempoColor.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TempoColor.line, lineWidth: 1)
        )
    }

    private var weekNavBar: some View {
        HStack {
            Button { viewModel.goToPrevWeek(store: store) } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2).foregroundStyle(TempoColor.primary)
            }
            Spacer()
            HStack(spacing: 8) {
                Text("Week of \(viewModel.weekDisplayString)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)
                Button {
                    viewModel.saveCurrent(store: store)
                } label: {
                    Image(systemName: "arrow.clockwise.circle")
                        .font(.headline)
                        .foregroundStyle(TempoColor.primary)
                }
                .buttonStyle(.plain)
            }
            Spacer()
            Button { viewModel.goToNextWeek(store: store) } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2).foregroundStyle(TempoColor.primary)
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    NavigationStack { PlannerView() }
        .environment(AppDataStore())
}
