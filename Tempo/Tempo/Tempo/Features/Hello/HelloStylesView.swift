import SwiftUI

struct HelloStylesView: View {
    private let accent = TempoColor.primary
    private let surface = TempoColor.surface
    private let ink = TempoColor.ink

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroSection
                typeSection
                actionSection
                colorSection
            }
            .padding(24)
        }
        .background(
            TempoGradient.appBackground
        )
        .navigationTitle("Hello Styles")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hello styles")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(ink)

            Text("Tempo's Hello Style screen with core style elements.")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                styleBadge(title: "Rounded")
                styleBadge(title: "Bright")
                styleBadge(title: "Native")
            }

            NavigationLink {
                HelloWorldView()
            } label: {
                Label("Go to Hello World", systemImage: "arrow.left.circle")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    TempoGradient.hero
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: accent.opacity(0.2), radius: 18, y: 10)
        .foregroundStyle(.white)
    }

    private var typeSection: some View {
        sectionCard(title: "Typography") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Display")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(ink)

                Text("Headline")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(ink)

                Text("This is an example of the body text for our application.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Text("Caption")
                    .font(.caption.weight(.medium))
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundStyle(accent)
            }
        }
    }

    private var actionSection: some View {
        sectionCard(title: "Controls") {
            VStack(alignment: .leading, spacing: 14) {
                Button {
                } label: {
                    Text("Primary action")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(accent)

                Button {
                } label: {
                    Text("Secondary action")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(accent)

                HStack(spacing: 10) {
                    stylePill(title: "Calm", fill: surface, textColor: ink)
                    stylePill(title: "Focused", fill: accent.opacity(0.12), textColor: accent)
                    stylePill(title: "Ready", fill: Color.green.opacity(0.15), textColor: .green)
                }
            }
        }
    }

    private var colorSection: some View {
        sectionCard(title: "Palette") {
            HStack(spacing: 12) {
                paletteSwatch(name: "Accent", color: accent)
                paletteSwatch(name: "Surface", color: surface)
                paletteSwatch(name: "Font Color", color: ink)
            }
        }
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(ink)

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TempoColor.line, lineWidth: 1)
        )
    }

    private func styleBadge(title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.18))
            .clipShape(Capsule())
    }

    private func stylePill(title: String, fill: Color, textColor: Color) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(textColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(fill)
            .clipShape(Capsule())
    }

    private func paletteSwatch(name: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(color)
                .frame(height: 80)

            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        HelloStylesView()
    }
}
