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

            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        isShowingSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }
            
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
