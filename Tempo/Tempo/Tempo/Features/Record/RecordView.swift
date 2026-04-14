import SwiftUI

struct RecordView: View {
    @Environment(AppDataStore.self) private var store
    @State private var showingSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard
                Button { showingSheet = true } label: {
                    Label("Log a Run", systemImage: "plus.circle.fill")
                }.buttonStyle(TempoPrimaryButtonStyle())

                Button {} label: {
                    Label("Link Device — Coming Soon", systemImage: "applewatch")
                }.buttonStyle(TempoSecondaryButtonStyle()).disabled(true).opacity(0.5)

                recentSection
            }
            .padding(.horizontal, 24).padding(.vertical, 20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Record")
        .sheet(isPresented: $showingSheet) { LogRunSheet(isPresented: $showingSheet) }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Log a Run")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(TempoColor.ink)
            Text("Record your workouts and track your progress over time.")
                .font(.subheadline)
                .foregroundStyle(TempoColor.slate)
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

    private var recentSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Recent Runs").font(.title3.weight(.semibold)).foregroundStyle(TempoColor.ink)
                let recent = Array(store.activities.prefix(5))
                if recent.isEmpty {
                    Text("No runs yet. Tap \"Log a Run\" to get started.")
                        .font(.subheadline).foregroundStyle(TempoColor.slate)
                } else {
                    ForEach(recent) { a in
                        ActivityRowView(activity: a, store: store)
                        if a.id != recent.last?.id { Divider() }
                    }
                }
            }
        }
    }
}

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
                        TextField("e.g. Morning Easy Run", text: $name).textFieldStyle(TempoTextFieldStyle())
                    }
                    field("Date") {
                        DatePicker("", selection: $completionDate, displayedComponents: .date)
                            .datePickerStyle(.compact).labelsHidden()
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .background(TempoColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(TempoColor.line, lineWidth: 1))
                    }
                    field("Distance (miles)") {
                        TextField("0.0", text: $distanceText).textFieldStyle(TempoTextFieldStyle()).keyboardType(.decimalPad)
                    }
                    field("Duration (H:MM:SS or M:SS)") {
                        TextField("0:00:00", text: $durationText).textFieldStyle(TempoTextFieldStyle()).keyboardType(.numbersAndPunctuation)
                    }
                    HStack {
                        Text("Avg Pace").font(.subheadline).foregroundStyle(TempoColor.slate)
                        Spacer()
                        Text("\(computedPace) /mi").font(.subheadline.weight(.semibold)).foregroundStyle(TempoColor.primary)
                    }.padding(.horizontal, 4)

                    field("Category") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(RunCategory.allCases, id: \.self) { cat in
                                Button { selectedCategory = cat } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: iconName(for: cat))
                                        Text(cat.label).font(.subheadline.weight(.semibold))
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(selectedCategory == cat ? cat.color.opacity(0.12) : TempoColor.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedCategory == cat ? cat.color.opacity(0.7) : TempoColor.line, lineWidth: 1))
                                    .foregroundStyle(selectedCategory == cat ? cat.color : TempoColor.ink)
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    if let errorMessage {
                        Text(errorMessage).font(.caption).foregroundStyle(.red)
                    }
                }
                .padding(24)
            }
            .background(TempoGradient.appBackground.ignoresSafeArea())
            .navigationTitle("Log a Run").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { isPresented = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { submit() }.disabled(!canSubmit).fontWeight(.semibold)
                }
            }
        }
    }

    private func field<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(TempoColor.ink)
            content()
        }
    }

    private func submit() {
        guard let durationSecs = AppDataStore.parseDuration(durationText) else {
            errorMessage = "Invalid duration. Use H:MM:SS or M:SS."
            return
        }
        guard distanceMiles > 0 else { errorMessage = "Distance must be greater than 0."; return }
        store.addActivity(Activity(
            name: name.trimmingCharacters(in: .whitespaces),
            completionDate: AppDataStore.dateToISO(completionDate),
            uploadDate: AppDataStore.dateToISO(Date()),
            distanceMiles: distanceMiles,
            durationSeconds: durationSecs,
            category: selectedCategory
        ))
        isPresented = false
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

struct TempoTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(TempoColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(TempoColor.line, lineWidth: 1))
    }
}

#Preview { NavigationStack { RecordView() } }
