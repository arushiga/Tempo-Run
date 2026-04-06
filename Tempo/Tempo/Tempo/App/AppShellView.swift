import SwiftUI

struct AppShellView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(MainTab.home.title, systemImage: MainTab.home.symbolName)
            }
            .tag(MainTab.home)

            NavigationStack {
                PlannerView()
            }
            .tabItem {
                Label(MainTab.planner.title, systemImage: MainTab.planner.symbolName)
            }
            .tag(MainTab.planner)

            NavigationStack {
                ProfilePrototypeView()
            }
            .tabItem {
                Label(MainTab.profile.title, systemImage: MainTab.profile.symbolName)
            }
            .tag(MainTab.profile)
        }
        .tint(TempoColor.primary)
    }
}

#Preview {
    AppShellView()
}
