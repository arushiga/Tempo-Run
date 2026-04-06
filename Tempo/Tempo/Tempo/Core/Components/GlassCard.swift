import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(TempoColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(TempoColor.line, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
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
