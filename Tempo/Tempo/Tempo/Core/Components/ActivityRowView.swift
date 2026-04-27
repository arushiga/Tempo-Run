import SwiftUI

struct ActivityRowView: View {
    let activity: Activity
    let store: AppDataStore

    @State private var showingDetails = false

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(activity.category.color.opacity(0.12))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: iconName(for: activity.category))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(activity.category.color)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(activity.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)
                    .lineLimit(1)
                Text(AppDataStore.formatDisplayDate(activity.completionDate))
                    .font(.caption)
                    .foregroundStyle(TempoColor.slate)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.1f mi", activity.distanceMiles))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TempoColor.primary)
                Text("\(store.formatPace(activity.avgPaceSecondsPerMile))/mi")
                    .font(.caption)
                    .foregroundStyle(TempoColor.muted)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(TempoColor.slate)
        }
        .padding(14)
        .background(TempoColor.surfaceStrong)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TempoColor.lineStrong.opacity(0.85), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            ActivityDetailSheet(activity: activity, store: store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private func iconName(for category: RunCategory) -> String {
        switch category {
        case .easy:
            "figure.run"
        case .tempo:
            "bolt.fill"
        case .long:
            "road.lanes"
        case .race:
            "flag.checkered"
        }
    }
}

struct ActivityDetailSheet: View {
    let activity: Activity
    let store: AppDataStore

    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false

    private var currentActivity: Activity {
        store.activities.first(where: { $0.id == activity.id }) ?? activity
    }

    private var linkedRun: ScheduledRun? {
        store.linkedPlannedRun(for: currentActivity)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    HStack(spacing: 12) {
                        metricCard(title: "Distance", value: String(format: "%.1f mi", currentActivity.distanceMiles))
                        metricCard(title: "Duration", value: store.formatDuration(currentActivity.durationSeconds))
                    }

                    HStack(spacing: 12) {
                        metricCard(title: "Average Pace", value: "\(store.formatPace(currentActivity.avgPaceSecondsPerMile))/mi")
                        metricCard(title: "Category", value: currentActivity.category.label)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Run Details")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(TempoColor.ink)
                        detailRow("Logged Date", value: AppDataStore.formatDisplayDate(currentActivity.completionDate))
                        detailRow("Upload Date", value: AppDataStore.formatDisplayDate(currentActivity.uploadDate))
                        detailRow("Training Type", value: currentActivity.category.label)
                        if let linkedRun {
                            detailRow("Linked Plan", value: linkedRunSummary(linkedRun))
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Summary")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(TempoColor.ink)
                        Text(summaryText)
                            .font(.subheadline)
                            .foregroundStyle(TempoColor.slate)
                    }

                    if !currentActivity.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(TempoColor.ink)
                            Text(currentActivity.notes)
                                .font(.subheadline)
                                .foregroundStyle(TempoColor.slate)
                        }
                    }

                    VStack(spacing: 10) {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit Run", systemImage: "square.and.pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(TempoPrimaryButtonStyle())

                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete Run", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(TempoSecondaryButtonStyle())
                    }
                }
                .padding(24)
            }
            .background(TempoGradient.appBackground.ignoresSafeArea())
            .navigationTitle("Run Details")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingEditSheet) {
            ActivityEditorSheet(mode: .edit(currentActivity), store: store)
        }
        .alert("Delete Run?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                store.deleteActivity(id: currentActivity.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove the run from your history.")
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(currentActivity.category.color.opacity(0.14))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: iconName(for: currentActivity.category))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(currentActivity.category.color)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(currentActivity.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)
                Text(AppDataStore.formatDisplayDate(currentActivity.completionDate))
                    .font(.subheadline)
                    .foregroundStyle(TempoColor.slate)
            }

            Spacer()
        }
    }

    private var summaryText: String {
        "Completed a \(currentActivity.category.label.lowercased()) run covering \(String(format: "%.1f", currentActivity.distanceMiles)) miles in \(store.formatDuration(currentActivity.durationSeconds)) at an average pace of \(store.formatPace(currentActivity.avgPaceSecondsPerMile))/mi."
    }

    private func metricCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(TempoColor.slate)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(TempoColor.ink)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TempoColor.infoTile)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TempoColor.line, lineWidth: 1)
        )
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(TempoColor.slate)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TempoColor.ink)
        }
        .padding(.vertical, 2)
    }

    private func linkedRunSummary(_ run: ScheduledRun) -> String {
        "\(plannedRunDate(for: run)) • \(shortWeekdayLabel(for: run.day)) \(run.timeOfDay.rawValue) • \(run.type.rawValue) • \(String(format: "%.1f", run.distanceMiles)) mi"
    }

    private func shortWeekdayLabel(for dayIndex: Int) -> String {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dayIndex]
    }

    private func plannedRunDate(for run: ScheduledRun) -> String {
        AppDataStore.formatDisplayDate(currentActivity.completionDate)
    }

    private func iconName(for category: RunCategory) -> String {
        switch category {
        case .easy:
            "figure.run"
        case .tempo:
            "bolt.fill"
        case .long:
            "road.lanes"
        case .race:
            "flag.checkered"
        }
    }
}

struct ActivityEditorSheet: View {
    enum Mode {
        case create
        case edit(Activity)

        var title: String {
            switch self {
            case .create:
                "Log a Run"
            case .edit:
                "Edit Run"
            }
        }
    }

    let mode: Mode
    let store: AppDataStore

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var completionDate = Date()
    @State private var distanceText = ""
    @State private var durationText = ""
    @State private var selectedCategory: RunCategory = .easy
    @State private var notes = ""
    @State private var selectedLinkedPlannedRunID: String?
    @State private var errorMessage: String?
    @State private var plannedRunOptions: [ScheduledRun] = []

    private var distanceMiles: Double { Double(distanceText) ?? 0 }
    private var computedPace: String {
        guard let secs = AppDataStore.parseDuration(durationText), secs > 0, distanceMiles > 0 else { return "--:--" }
        return store.formatPace(Int(Double(secs) / distanceMiles))
    }
    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && distanceMiles > 0
            && AppDataStore.parseDuration(durationText) != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    field("Run Name") {
                        TextField("e.g. Morning Easy Run", text: $name)
                            .textFieldStyle(TempoTextFieldStyle())
                    }
                    field("Date") {
                        DatePicker("", selection: $completionDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(TempoColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(TempoColor.line, lineWidth: 1))
                    }
                    field("Distance (miles)") {
                        TextField("0.0", text: $distanceText)
                            .textFieldStyle(TempoTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    field("Duration (H:MM:SS or M:SS)") {
                        TextField("0:00:00", text: $durationText)
                            .textFieldStyle(TempoTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                    }
                    HStack {
                        Text("Avg Pace")
                            .font(.subheadline)
                            .foregroundStyle(TempoColor.slate)
                        Spacer()
                        Text("\(computedPace) /mi")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(TempoColor.primary)
                    }
                    .padding(.horizontal, 4)

                    field("Category") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(RunCategory.allCases, id: \.self) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: iconName(for: category))
                                        Text(category.label)
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedCategory == category ? category.color.opacity(0.12) : TempoColor.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(selectedCategory == category ? category.color.opacity(0.7) : TempoColor.line, lineWidth: 1)
                                    )
                                    .foregroundStyle(selectedCategory == category ? category.color : TempoColor.ink)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    field("Link to Planned Run") {
                        Menu {
                            Button("No linked planned run") {
                                selectedLinkedPlannedRunID = nil
                            }

                            ForEach(plannedRunOptions, id: \.id) { run in
                                Button(plannedRunLabel(for: run)) {
                                    selectedLinkedPlannedRunID = run.id.uuidString
                                }
                            }
                        } label: {
                            HStack {
                                Text(linkedRunMenuTitle)
                                    .font(.subheadline)
                                    .foregroundStyle(selectedLinkedPlannedRunID == nil ? TempoColor.slate : TempoColor.ink)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(TempoColor.slate)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(TempoColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(TempoColor.line, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }

                    field("Notes") {
                        TextEditor(text: $notes)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 110)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(TempoColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(TempoColor.line, lineWidth: 1))
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(24)
            }
            .background(TempoGradient.appBackground.ignoresSafeArea())
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        submit()
                    }
                    .disabled(!canSubmit)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                populateInitialValues()
                refreshPlannedRunOptions()
            }
            .onChange(of: completionDate) { _, _ in
                refreshPlannedRunOptions()
            }
        }
    }

    private func populateInitialValues() {
        guard case .edit(let activity) = mode else { return }
        name = activity.name
        completionDate = AppDataStore.isoToDate(activity.completionDate) ?? Date()
        distanceText = activity.distanceMiles.rounded() == activity.distanceMiles ? "\(Int(activity.distanceMiles))" : String(format: "%.1f", activity.distanceMiles)
        durationText = store.formatDuration(activity.durationSeconds)
        selectedCategory = activity.category
        notes = activity.notes
        selectedLinkedPlannedRunID = activity.linkedPlannedRunID
    }

    private func field<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TempoColor.ink)
            content()
        }
    }

    private func submit() {
        guard let durationSecs = AppDataStore.parseDuration(durationText) else {
            errorMessage = "Invalid duration. Use H:MM:SS or M:SS."
            return
        }
        guard distanceMiles > 0 else {
            errorMessage = "Distance must be greater than 0."
            return
        }

        let normalizedName = name.trimmingCharacters(in: .whitespaces)

        switch mode {
        case .create:
            store.addActivity(Activity(
                name: normalizedName,
                completionDate: AppDataStore.dateToISO(completionDate),
                uploadDate: AppDataStore.dateToISO(Date()),
                distanceMiles: distanceMiles,
                durationSeconds: durationSecs,
                category: selectedCategory,
                notes: cleanedNotes,
                linkedPlannedRunID: selectedLinkedPlannedRunID
            ))
        case .edit(let existing):
            store.updateActivity(Activity(
                id: existing.id,
                name: normalizedName,
                completionDate: AppDataStore.dateToISO(completionDate),
                uploadDate: existing.uploadDate,
                distanceMiles: distanceMiles,
                durationSeconds: durationSecs,
                category: selectedCategory,
                notes: cleanedNotes,
                linkedPlannedRunID: selectedLinkedPlannedRunID
            ))
        }

        dismiss()
    }

    private func iconName(for category: RunCategory) -> String {
        switch category {
        case .easy:
            "figure.run"
        case .tempo:
            "bolt.fill"
        case .long:
            "road.lanes"
        case .race:
            "flag.checkered"
        }
    }

    private var cleanedNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var linkedRunMenuTitle: String {
        guard
            let selectedLinkedPlannedRunID,
            let run = plannedRunOptions.first(where: { $0.id.uuidString == selectedLinkedPlannedRunID })
        else {
            return plannedRunOptions.isEmpty ? "No planned runs available for this week" : "Select a planned run"
        }

        return plannedRunLabel(for: run)
    }

    private func refreshPlannedRunOptions() {
        let weekStart = AppDataStore.weekStart(forISODate: AppDataStore.dateToISO(completionDate)) ?? AppDataStore.currentWeekStart()
        plannedRunOptions = store.cachedWeekPlan(weekStart)
            .sorted { lhs, rhs in
                if lhs.day == rhs.day {
                    return lhs.timeOfDay.rawValue < rhs.timeOfDay.rawValue
                }
                return lhs.day < rhs.day
            }

        if let selectedLinkedPlannedRunID,
           plannedRunOptions.contains(where: { $0.id.uuidString == selectedLinkedPlannedRunID }) == false {
            self.selectedLinkedPlannedRunID = nil
        }
    }

    private func plannedRunLabel(for run: ScheduledRun) -> String {
        "\(plannedRunDate(for: run)) • \(shortWeekdayLabel(for: run.day)) \(run.timeOfDay.rawValue) • \(run.type.rawValue) • \(String(format: "%.1f", run.distanceMiles)) mi"
    }

    private func shortWeekdayLabel(for dayIndex: Int) -> String {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dayIndex]
    }

    private func plannedRunDate(for run: ScheduledRun) -> String {
        let weekStart = AppDataStore.weekStart(forISODate: AppDataStore.dateToISO(completionDate)) ?? AppDataStore.currentWeekStart()
        guard let weekStartDate = AppDataStore.isoToDate(weekStart) else {
            return AppDataStore.formatDisplayDate(weekStart)
        }
        let date = weekStartDate.addingTimeInterval(Double(run.day) * 86400)
        return AppDataStore.formatDisplayDate(AppDataStore.dateToISO(date))
    }
}
