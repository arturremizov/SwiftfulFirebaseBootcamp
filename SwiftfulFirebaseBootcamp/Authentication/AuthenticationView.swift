//
//  AuthenticationView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 3.08.23.
//

import SwiftUI
import GoogleSignInSwift

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    private let authManager: AuthenticationManager
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }
    
    func signInGoogle() async throws {
        let tokens = try await SignInGoogleHelper.signIn()
        try await authManager.signInWithGoogle(idToken: tokens.idToken, accessToken: tokens.accessToken)
    }
    
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let authResult = try await helper.startSignInWithAppleFlow()
        try await authManager.signInWithApple(idToken: authResult.idTokenString, nonce: authResult.nonce, fullName: authResult.fullName)
    }
    
    func signInAnonymous() async throws {
        try await authManager.signInAnonymously()
    }
}

struct AuthenticationView: View {
    
    @Binding var isShowingSignInView: Bool
    @StateObject private var viewModel: AuthenticationViewModel
    @EnvironmentObject private var authManager: AuthenticationManager

    init(isShowingSignInView: Binding<Bool>, viewModel: AuthenticationViewModel) {
        self._isShowingSignInView = isShowingSignInView
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            Button {
                signInAnonymously()
            } label: {
                Text("Sign In Anonymously")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.orange)
                    .cornerRadius(10, antialiased: true)
            }
            
            NavigationLink {
                SignInEmailView(
                    isShowingSignInView: $isShowingSignInView,
                    viewModel: SignInEmailViewModel(authManager: authManager)
                )
            } label: {
                Text("Sign In with Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.blue)
                    .cornerRadius(10, antialiased: true)
            }

            GoogleSignInButton(
                viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal),
                action: signInGoogle
            )
            
            SignInWithAppleButton(type: .default, style: .black, action: signInApple)
                .frame(height: 55)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(
                isShowingSignInView: .constant(false),
                viewModel: AuthenticationViewModel(authManager: .init())
            )
        }
        .environmentObject(AuthenticationManager())
    }
}

// MARK: - Methods
extension AuthenticationView {
    
    private func signInAnonymously() {
        Task {
            do {
                try await viewModel.signInAnonymous()
                isShowingSignInView = false
            } catch {
                print(error)
            }
        }
    }
    
    private func signInGoogle() {
        Task {
            do {
                try await viewModel.signInGoogle()
                isShowingSignInView = false
            } catch {
                print(error)
            }
        }
    }
    
    private func signInApple() {
        Task {
            do {
                try await viewModel.signInApple()
                isShowingSignInView = false
            } catch {
                print(error)
            }
        }
    }
}
