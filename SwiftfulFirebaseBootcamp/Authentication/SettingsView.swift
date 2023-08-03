//
//  SettingsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 3.08.23.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    private let authManager: AuthenticationManager
    init(authManager: AuthenticationManager = .shared) {
        self.authManager = authManager
    }
    
    func signOut() throws {
        try authManager.signOut()
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var isShowingSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        isShowingSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(isShowingSignInView: .constant(false))
        }
    }
}
