//
//  SettingsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 3.08.23.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    
    private let authManager: AuthenticationManager
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }
    
    func loadAuthProviders() {
        if let authProviders = try? authManager.getProviders() {
            self.authProviders = authProviders
        }
    }
    
    func signOut() throws {
        try authManager.signOut()
    }
    
    func resetPassword() async throws {
        let user = try authManager.getAuthenticatedUser()
        guard let email = user.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await authManager.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "hello123@gmail.com"
        try await authManager.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "hello123"
        try await authManager.updatePassword(password: password)
    }
}

struct SettingsView: View {
    
    @Binding var isShowingSignInView: Bool
    @StateObject private var viewModel: SettingsViewModel
    
    init(isShowingSignInView: Binding<Bool>, viewModel: SettingsViewModel) {
        self._isShowingSignInView = isShowingSignInView
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
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
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
        }
        .onAppear {
            viewModel.loadAuthProviders()
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(
                isShowingSignInView: .constant(false),
                viewModel: SettingsViewModel(authManager: .init())
            )
        }
    }
}

extension SettingsView {
    
    private var emailSection: some View {
        Section {
            Button("Reset password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Update password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("PASSWORD UPDATED!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Update email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("EMAIL UPDATED!")
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Email functions")
        }
    }
}
