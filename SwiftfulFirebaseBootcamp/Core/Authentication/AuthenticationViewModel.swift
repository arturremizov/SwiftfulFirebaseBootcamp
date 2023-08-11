//
//  AuthenticationViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 11.08.23.
//

import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    private let authManager: AuthenticationManager
    private let userManager: UserManager
    init(authManager: AuthenticationManager, userManager: UserManager) {
        self.authManager = authManager
        self.userManager = userManager
    }
    
    func signInGoogle() async throws {
        let tokens = try await SignInGoogleHelper.signIn()
        let user = try await authManager.signInWithGoogle(idToken: tokens.idToken, accessToken: tokens.accessToken)
        try await userManager.createNewUser(authUser: user)
    }
    
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let authResult = try await helper.startSignInWithAppleFlow()
        let user = try await authManager.signInWithApple(idToken: authResult.idTokenString, nonce: authResult.nonce, fullName: authResult.fullName)
        try await userManager.createNewUser(authUser: user)
    }
    
    func signInAnonymous() async throws {
        let user = try await authManager.signInAnonymously()
        try await userManager.createNewUser(authUser: user)
    }
}
