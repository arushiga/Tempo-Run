import SwiftUI

struct AppShellView: View {
    @State private var selectedTab: MainTab = .home
    @State private var store = AppDataStore()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label(MainTab.home.title, systemImage: MainTab.home.symbolName) }
            .tag(MainTab.home)

            NavigationStack {
                PlannerView()
            }
            .tabItem { Label(MainTab.planner.title, systemImage: MainTab.planner.symbolName) }
            .tag(MainTab.planner)

            NavigationStack {
                RecordView()
            }
            .tabItem { Label(MainTab.record.title, systemImage: MainTab.record.symbolName) }
            .tag(MainTab.record)

            NavigationStack {
                ActivityView()
            }
            .tabItem { Label(MainTab.activity.title, systemImage: MainTab.activity.symbolName) }
            .tag(MainTab.activity)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label(MainTab.profile.title, systemImage: MainTab.profile.symbolName) }
            .tag(MainTab.profile)
        }
        .tint(TempoColor.primary)
        .environment(store)
    }
}

#Preview {
    AppShellView()
}
