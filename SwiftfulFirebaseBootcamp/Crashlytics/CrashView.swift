//
//  CrashView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 31.08.23.
//

import SwiftUI
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

struct CrashView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 40.0) {
                Button("Click me 1") {
                    CrashManager.shared.addLog(message: "button_1_clicked")
                    let myString: String? = nil
                    guard let myString else {
                        CrashManager.shared.sendNonFatal(error: URLError(.dataNotAllowed))
                        return
                    }
                    let string2 = myString
                    print(string2)
                }
                Button("Click me 2") {
                    CrashManager.shared.addLog(message: "button_2_clicked")
                    fatalError("This is a fatal crash.")
                }
                Button("Click me 3") {
                    CrashManager.shared.addLog(message: "button_3_clicked")

                    let array = [String]()
                    let item = array[0]
                    print(item)
                }
            }
        }
        .onAppear {
            CrashManager.shared.set(userId: "ABC123")
            CrashManager.shared.set(isPrevium: true)
            CrashManager.shared.addLog(message: "crash_view_appeared")
            CrashManager.shared.addLog(message: "Crash view appeared on user's screen.")
        }
    }
}

struct CrashView_Previews: PreviewProvider {
    static var previews: some View {
        CrashView()
    }
}
