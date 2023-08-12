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
        let authUser = try await authManager.signInWithGoogle(idToken: tokens.idToken, accessToken: tokens.accessToken)
        let appUser = AppUser(authUser: authUser)
        try await userManager.createNewUser(appUser)
    }
    
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let authResult = try await helper.startSignInWithAppleFlow()
        let authUser = try await authManager.signInWithApple(idToken: authResult.idTokenString, nonce: authResult.nonce, fullName: authResult.fullName)
        let appUser = AppUser(authUser: authUser)
        try await userManager.createNewUser(appUser)
    }
    
    func signInAnonymous() async throws {
        let authUser = try await authManager.signInAnonymously()
        let appUser = AppUser(authUser: authUser)
        try await userManager.createNewUser(appUser)
    }
}
