//
//  SignInGoogleHelper.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 5.08.23.
//

import UIKit
import GoogleSignIn

final class SignInGoogleHelper {
    
    @MainActor
    static func signIn() async throws -> (idToken: String, accessToken: String) {
        guard let topViewController = UIApplication.shared.topMostController() else {
            throw URLError(.cannotFindHost)
        }
        
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
        
        let user = signInResult.user
        guard let idToken = user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        return (idToken, user.accessToken.tokenString)
    }
}
