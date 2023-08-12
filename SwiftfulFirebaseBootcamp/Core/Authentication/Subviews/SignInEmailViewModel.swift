//
//  SignInEmailViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 11.08.23.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    private let authManager: AuthenticationManager
    private let userManager: UserManager
    init(authManager: AuthenticationManager, userManager: UserManager) {
        self.authManager = authManager
        self.userManager = userManager
    }
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        let authUser = try await authManager.createUser(email: email, password: password)
        let appUser = AppUser(authUser: authUser)
        try await userManager.createNewUser(appUser)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        try await authManager.signInUser(email: email, password: password)
    }
}
