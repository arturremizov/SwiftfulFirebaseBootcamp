//
//  SignInAppleHelper.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 8.08.23.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

struct SignInWithAppleButton: UIViewRepresentable {
    
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    let action: () -> Void
    
    func makeUIView(context: Context) -> some ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: type, style: style)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTapButton), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator: NSObject {
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func didTapButton() {
            action()
        }
    }
}

struct SignInAppleAuthResult {
    let idTokenString: String
    let nonce: String
    let fullName: PersonNameComponents?
    let email: String?
}

final class SignInAppleHelper: NSObject {
    
    typealias SignInAppleCompletion = (Result<SignInAppleAuthResult, Error>) -> Void
    private var currentNonce: String?
    private var completionHandler: SignInAppleCompletion?

    func startSignInWithAppleFlow() async throws -> SignInAppleAuthResult {
        try await withCheckedThrowingContinuation { continuation in
            startSignInWithAppleFlow { result in
                switch result {
                case .success(let authResult):
                    continuation.resume(returning: authResult)
                    return
                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
    
    func startSignInWithAppleFlow(completion: @escaping SignInAppleCompletion) {
        self.completionHandler = completion
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Helpers
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension SignInAppleHelper: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            print("Error getting apple authorization credential")
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        
        let authResult = SignInAppleAuthResult(
            idTokenString: idTokenString,
            nonce: nonce,
            fullName: appleIDCredential.fullName,
            email: appleIDCredential.email
        )
        completionHandler?(.success(authResult))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
        completionHandler?(.failure(URLError(.badServerResponse)))
    }
}

extension SignInAppleHelper: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }
}
