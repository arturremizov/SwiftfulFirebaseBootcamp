//
//  CrashView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 31.08.23.
//

import SwiftUI

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
