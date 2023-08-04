//
//  AuthenticationView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 3.08.23.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Binding var isShowingSignInView: Bool
    
    var body: some View {
        VStack {
            NavigationLink {
                SignInEmailView(isShowingSignInView: $isShowingSignInView)
            } label: {
                Text("Sign In with Email")
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
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(isShowingSignInView: .constant(false))
        }
    }
}