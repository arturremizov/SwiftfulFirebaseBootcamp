//
//  SignInEmailView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 3.08.23.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    private let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        try await authManager.createUser(email: email, password: password)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        try await authManager.signInUser(email: email, password: password)
    }
}

struct SignInEmailView: View {
    
    @Binding var isShowingSignInView: Bool
    @StateObject private var viewModel: SignInEmailViewModel
    
    init(isShowingSignInView: Binding<Bool>, viewModel: SignInEmailViewModel) {
        self._isShowingSignInView = isShowingSignInView
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10, antialiased: true)
            
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10, antialiased: true)
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        isShowingSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                    
                    do {
                        try await viewModel.signIn()
                        isShowingSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.blue)
                    .cornerRadius(10, antialiased: true)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Sign in with Email")
    }
}

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInEmailView(
                isShowingSignInView: .constant(false),
                viewModel: SignInEmailViewModel(authManager: .init())
            )
        }
    }
}
