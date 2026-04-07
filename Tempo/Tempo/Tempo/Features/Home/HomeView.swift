import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                prototypeStatus
                quickLinks
            }
            .padding(20)
        }
        .background(TempoGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Tempo")
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tempo")
                .font(.system(size: 34, weight: .bold, design: .rounded))

            Text("Native SwiftUI shell for the running planner prototype.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))

            Text("This home screen is the launch point for the Assignment 5 prototypes.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
        }
        .foregroundStyle(.white)
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(TempoGradient.hero)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: TempoColor.primary.opacity(0.24), radius: 18, y: 10)
    }

    private var prototypeStatus: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Prototype Status")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                statusRow(title: "Hello World", value: "Complete")
                statusRow(title: "Hello Styles", value: "Complete")
                statusRow(title: "Planner", value: "Scaffolded")
                statusRow(title: "Profile", value: "Scaffolded")
                statusRow(title: "Auth + Firebase", value: "Complete")
            }
        }
    }

    private var quickLinks: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Demo Screens")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(TempoColor.ink)

                NavigationLink {
                    HelloWorldView()
                } label: {
                    Label("Open Hello World", systemImage: "hand.wave")
                }
                .buttonStyle(TempoPrimaryButtonStyle())

                NavigationLink {
                    HelloStylesView()
                } label: {
                    Label("Open Hello Styles", systemImage: "paintpalette")
                }
                .buttonStyle(TempoSecondaryButtonStyle())

                NavigationLink {
                    LoginView()
                } label: {
                    Label("Open Login Prototype", systemImage: "person.crop.circle")
                }
                .buttonStyle(TempoSecondaryButtonStyle())
            }
        }
    }

    private func statusRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(TempoColor.ink)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TempoColor.primary)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
