//
//  AnalyticsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 2.09.23.
//

import SwiftUI
import FirebaseAnalytics
import FirebaseAnalyticsSwift

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}
    
    func logEvent(name: String, params: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    func setUserId(userId: String) {
        Analytics.setUserID(userId)
    }
    
    func setUserProperty(value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}

struct AnalyticsView: View {
    var body: some View {
        VStack(spacing: 40) {
            Button("Click me!") {
                AnalyticsManager.shared.logEvent(name: "AnalyticsView_button_click")
            }
            Button("Click me too!") {
                AnalyticsManager.shared.logEvent(name: "AnalyticsView_secondary_button_click", params: ["screen_title": "Hello, World!"])
            }
        }
        .analyticsScreen(name: "AnalyticsView")
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "AnalyticsView_view_appear")
        }
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: "AnalyticsView_view_disappear")
            AnalyticsManager.shared.setUserId(userId: "ABC123")
            AnalyticsManager.shared.setUserProperty(value: "true", forName: "user_is_premium")
        }
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
    }
}
