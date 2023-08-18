//
//  RootView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 3.08.23.
//

import SwiftUI

struct RootView: View {
    
    @State private var isShowingSignInView: Bool = false
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var userManager: UserManager
    
    var body: some View {
        ZStack {
            if !isShowingSignInView {
                TabbarView(isShowingSignInView: $isShowingSignInView)
            }
        }
        .onAppear {
            let user = try? authManager.getAuthenticatedUser()
            isShowingSignInView = user == nil
        }
        .fullScreenCover(isPresented: $isShowingSignInView) {
            NavigationStack {
                AuthenticationView(
                    isShowingSignInView: $isShowingSignInView,
                    viewModel: AuthenticationViewModel(
                        authManager: authManager,
                        userManager: userManager
                    )
                )
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AuthenticationManager())
            .environmentObject(UserManager())
            .environmentObject(ProductsManager())
    }
}
