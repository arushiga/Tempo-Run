import SwiftUI

struct HelloWorldView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .font(.system(size: 54))
                .foregroundStyle(.tint)

            Text("Hello, world!")
                .font(.largeTitle.weight(.bold))

            Text("This is the basic SwiftUI hello page for Tempo.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            NavigationLink {
                HelloStylesView()
            } label: {
                Label("Go to Hello Styles", systemImage: "paintpalette")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(Color(.systemBackground))
        .navigationTitle("Hello World")
    }
}

#Preview {
    NavigationStack {
        HelloWorldView()
    }
}
