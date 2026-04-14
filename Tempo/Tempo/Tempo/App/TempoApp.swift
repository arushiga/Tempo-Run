//
//  TempoApp.swift
//  Tempo
//
//  Created by Eric Chen on 4/2/26.
//


import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct TempoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var auth = AuthViewModel()
    @State private var store = AppDataStore()

    var body: some Scene {
        WindowGroup {
            if auth.user != nil {
                AppShellView()
                    .environmentObject(auth)
                    .environment(store)
            } else {
                NavigationStack {
                    LoginView()
                }
                .environmentObject(auth)
                .environment(store)
            }
        }
    }
}
