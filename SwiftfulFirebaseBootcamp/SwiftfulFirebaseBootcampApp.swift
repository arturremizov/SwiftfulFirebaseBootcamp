//
//  SwiftfulFirebaseBootcampApp.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 3.08.23.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct SwiftfulFirebaseBootcampApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var authManager = AuthenticationManager()
    @StateObject var userManager = UserManager()
    @StateObject var productsManager = ProductsManager()
    @StateObject var storageManager = StorageManager()

    var body: some Scene {
        WindowGroup {
            AnalyticsView()
//            PerformanceView()
//            CrashView()
//            RootView()
//                .environmentObject(authManager)
//                .environmentObject(userManager)
//                .environmentObject(productsManager)
//                .environmentObject(storageManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}
