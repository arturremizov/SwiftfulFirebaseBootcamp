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
    @Published var currentUser: AuthUser? = nil
    
    private let authManager: AuthenticationManager
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }
    
    func loadAuthProviders() {
        if let authProviders = try? authManager.getProviders() {
            self.authProviders = authProviders
        }
    }
    
    func loadAuthUser() {
        self.currentUser = try? authManager.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try authManager.signOut()
    }
    
    func deleteAccount() async throws {
        try await authManager.deleteUser()
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
    
    func linkGoogleAccount() async throws {
        let tokens = try await SignInGoogleHelper.signIn()
        self.currentUser = try await authManager.linkGoogle(idToken: tokens.idToken, accessToken: tokens.accessToken)
    }
    
    func linkAppleAccount() async throws {
        let helper = SignInAppleHelper()
        let authResult = try await helper.startSignInWithAppleFlow()
        self.currentUser = try await authManager.linkApple(idToken: authResult.idTokenString, nonce: authResult.nonce, fullName: authResult.fullName)
    }
    
    func linkEmailAccount() async throws {
        let email = "hello123@gmail.com"
        let password = "hello123"
        self.currentUser = try await authManager.linkEmail(email: email, password: password)
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
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        isShowingSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Delete account")
            }
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            } else if viewModel.currentUser?.isAnonymous == true {
                anonymousSection
            }
        }
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
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
    
    private var anonymousSection: some View {
        Section {
            Button("Link Google Account") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Link Apple Account") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("APPLE LINKED!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Link email account") {
                Task {
                    do {
                        try await viewModel.linkEmailAccount()
                        print("EMAIL LINKED!")
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Create account")
        }
    }
}
