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

     var body: some Scene {
         WindowGroup {
             if auth.user != nil {
                 // User is logged in — show main app
                 AppShellView()
                     .environmentObject(auth)
             } else {
                 // Not logged in — show login
                 NavigationStack {
                     LoginView()
                 }
                 .environmentObject(auth)
             }
         }
     }

}
