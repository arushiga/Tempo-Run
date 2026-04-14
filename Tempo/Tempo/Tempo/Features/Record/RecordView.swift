import SwiftUI

struct RecordView: View {
    @Environment(AppDataStore.self) private var store
    @State private var showingLogSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard
                logButton
                linkDeviceButton
                recentRunsSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Record")
        .sheet(isPresented: $showingLogSheet) {
            LogRunSheet(isPresented: $showingLogSheet)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Log a Run")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Record your workouts and track your progress over time.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(TempoGradient.hero)
        )
        .shadow(color: TempoColor.primary.opacity(0.24), radius: 18, y: 10)
    }

    private var logButton: some View {
        Button {
            showingLogSheet = true
        } label: {
            Label("Log a Run", systemImage: "plus.circle.fill")
        }
        .buttonStyle(TempoPrimaryButtonStyle())
    }

    private var linkDeviceButton: some View {
        Button {} label: {
            Label("Link Device — Coming Soon", systemImage: "applewatch")
        }
        .buttonStyle(TempoSecondaryButtonStyle())
        .disabled(true)
        .opacity(0.5)
    }

    private var recentRunsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Recent Runs")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                let recent = Array(store.activities.prefix(5))
                if recent.isEmpty {
                    Text("No runs logged yet. Tap "Log a Run" to get started.")
                        .font(.subheadline)
                        .foregroundStyle(TempoColor.slate)
                } else {
                    ForEach(recent) { activity in
                        ActivityRowView(activity: activity, store: store)
                        if activity.id != recent.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Log Run Sheet

struct LogRunSheet: View {
    @Binding var isPresented: Bool
    @Environment(AppDataStore.self) private var store

    @State private var name = ""
    @State private var completionDate = Date()
    @State private var distanceText = ""
    @State private var durationText = ""
    @State private var selectedCategory: RunCategory = .easy
    @State private var errorMessage: String?

    private var distanceMiles: Double { Double(distanceText) ?? 0 }

    private var computedPace: String {
        guard let secs = AppDataStore.parseDuration(durationText), secs > 0, distanceMiles > 0 else {
            return "--:--"
        }
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
                    // Name
                    fieldSection(title: "Run Name") {
                        TextField("e.g. Morning Easy Run", text: $name)
                            .textFieldStyle(TempoTextFieldStyle())
                    }

                    // Date
                    fieldSection(title: "Date") {
                        DatePicker("", selection: $completionDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // Distance
                    fieldSection(title: "Distance (miles)") {
                        TextField("0.0", text: $distanceText)
                            .textFieldStyle(TempoTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }

                    // Duration
                    fieldSection(title: "Duration (H:MM:SS or M:SS)") {
                        TextField("0:00:00", text: $durationText)
                            .textFieldStyle(TempoTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                    }

                    // Auto pace
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

                    // Category
                    fieldSection(title: "Category") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(RunCategory.allCases, id: \.self) { cat in
                                Button {
                                    selectedCategory = cat
                                } label: {
                                    HStack(spacing: 8) {
                                        Text(cat.emoji)
                                        Text(cat.label)
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedCategory == cat
                                            ? cat.color.opacity(0.18)
                                            : Color.white.opacity(0.8)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(selectedCategory == cat ? cat.color : Color.gray.opacity(0.2), lineWidth: 2)
                                    )
                                    .foregroundStyle(selectedCategory == cat ? cat.color : TempoColor.ink)
                                }
                                .buttonStyle(.plain)
                            }
                        }
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
            .navigationTitle("Log a Run")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { submit() }
                        .disabled(!canSubmit)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func fieldSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TempoColor.ink)
            content()
        }
    }

    private func submit() {
        guard let durationSecs = AppDataStore.parseDuration(durationText) else {
            errorMessage = "Invalid duration format. Use H:MM:SS or M:SS."
            return
        }
        guard distanceMiles > 0 else {
            errorMessage = "Distance must be greater than 0."
            return
        }

        let activity = Activity(
            name: name.trimmingCharacters(in: .whitespaces),
            completionDate: AppDataStore.dateToISO(completionDate),
            uploadDate: AppDataStore.dateToISO(Date()),
            distanceMiles: distanceMiles,
            durationSeconds: durationSecs,
            category: selectedCategory
        )
        store.addActivity(activity)
        isPresented = false
    }
}

// MARK: - Text field style helper

struct TempoTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        RecordView()
    }
}
