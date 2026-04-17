import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(TempoColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(TempoColor.line, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.035), radius: 10, y: 2)
    }
}

#Preview {
    ZStack {
        TempoGradient.appBackground.ignoresSafeArea()

        GlassCard {
            Text("Glass Card")
                .font(.title3.weight(.semibold))
        }
        .padding()
    }
}
