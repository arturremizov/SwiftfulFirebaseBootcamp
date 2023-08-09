//
//  AuthenticationManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 3.08.23.
//

import Foundation
import FirebaseAuth

struct AuthUser {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager: ObservableObject {

    func getAuthenticatedUser() throws -> AuthUser {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthUser(user: user)
    }
    
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        return providerData.map {
            guard let option = AuthProviderOption(rawValue: $0.providerID) else {
                fatalError("Provider option not found: \($0.providerID)")
            }
            return option
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MARK: - Sign In Email
extension AuthenticationManager {
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthUser {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthUser(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthUser {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUser(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updateEmail(to: email)
    }
}

// MARK: - Sign In SSO
extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> AuthUser {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        return try await signIn(with: credential)
    }
    
    @discardableResult
    func signInWithApple(idToken: String, nonce: String, fullName: PersonNameComponents?) async throws -> AuthUser {
        let credential = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: nonce, fullName: fullName)
        return try await signIn(with: credential)
    }
    
    func signIn(with credential: AuthCredential) async throws -> AuthUser {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthUser(user: authDataResult.user)
    }
}

// MARK: - Sign In Anonymous
extension AuthenticationManager {
    
    @discardableResult
    func signInAnonymously() async throws -> AuthUser {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthUser(user: authDataResult.user)
    }
    
    func linkEmail(email: String, password: String) async throws -> AuthUser {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await link(credential)
    }
    
    func linkApple(idToken: String, nonce: String, fullName: PersonNameComponents?) async throws -> AuthUser {
        let credential = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: nonce, fullName: fullName)
        return try await link(credential)
    }
    
    func linkGoogle(idToken: String, accessToken: String) async throws -> AuthUser {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        return try await link(credential)
    }
    
    private func link(_ credential: AuthCredential) async throws -> AuthUser {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        let authDataResult = try await user.link(with: credential)
        return AuthUser(user: authDataResult.user)
    }
}
