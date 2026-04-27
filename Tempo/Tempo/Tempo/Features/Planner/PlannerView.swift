import SwiftUI

struct PlannerView: View {
    @State private var viewModel = PlannerViewModel()
    @Environment(AppDataStore.self) private var store
    @FocusState private var focusedField: MileageFieldID?
    @State private var draftMiles: [MileageFieldID: String] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                plannerHeader
                weekNavBar
                PlannerGridView(
                    viewModel: viewModel,
                    draftMiles: $draftMiles,
                    focusedField: $focusedField,
                    onCancel: cancelEditing,
                    onCommit: commitEditing
                )
                RunTypePickerView()
                PlannerStatsView(viewModel: viewModel)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Planner")
        .task {
            viewModel.scheduledRuns = await store.loadWeekPlan(viewModel.currentWeekStart)
        }
        .onChange(of: viewModel.scheduledRuns) { _, _ in
            Task {
                try? await Task.sleep(for: .seconds(1))
                viewModel.saveCurrent(store: store)
            }
        }
        .onDisappear { viewModel.saveCurrent(store: store) }
        .overlay(alignment: .bottom) {
            if focusedField != nil {
                HStack {
                    Button { cancelEditing() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(12)
                    }
                    Spacer()
                    Button { commitEditing() } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(12)
                    }
                }
                .background(.bar)
            }
        }
    }
  
    func commitEditing() {
        guard let activeField = focusedField else { return }
        let rawValue = draftMiles[activeField] ?? "0"
        let normalized = rawValue
            .replacingOccurrences(of: "mi", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let miles = max(0, min(Double(normalized) ?? 0, 26.2))
        viewModel.setDistance(miles, for: activeField.runID)
        let formatted = MileageFormatter.format(miles)
        for key in draftMiles.keys where key.runID == activeField.runID {
            draftMiles[key] = formatted
        }
        focusedField = nil
    }

    func cancelEditing() {
        guard let activeField = focusedField else { return }
        let currentMiles = viewModel.scheduledRuns.first(where: { $0.id == activeField.runID })?.distanceMiles ?? 0
        let formatted = MileageFormatter.format(currentMiles)
        for key in draftMiles.keys where key.runID == activeField.runID {
            draftMiles[key] = formatted
        }
        focusedField = nil
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
            Button {
                Task {
                    await viewModel.goToPrevWeek(store: store)
                }
            } label: {
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
            Button {
                Task {
                    await viewModel.goToNextWeek(store: store)
                }
            } label: {
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
