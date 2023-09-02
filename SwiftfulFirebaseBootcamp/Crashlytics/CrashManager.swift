//
//  CrashManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 1.09.23.
//

import FirebaseCrashlytics

final class CrashManager {

    static let shared = CrashManager()
    private init() {}
    
    func set(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    func set(value: String, key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    func set(isPrevium: Bool) {
        set(value: isPrevium.description.lowercased(), key: "user_is_premium")
    }
    
    func addLog(message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    func sendNonFatal(error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
}
