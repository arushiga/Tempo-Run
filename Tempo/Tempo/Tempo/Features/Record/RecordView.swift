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
        .sheet(isPresented: $showingSheet) {
            ActivityEditorSheet(mode: .create, store: store)
        }
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
