//
//  SettingsViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 11.08.23.
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
