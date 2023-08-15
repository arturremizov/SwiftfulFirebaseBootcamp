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
    @EnvironmentObject private var productsManager: ProductsManager
    
    var body: some View {
        ZStack {
            if !isShowingSignInView {
                NavigationStack {
                    
                    ProductsView(
                        viewModel: ProductsViewModel(productsManager: productsManager)
                    )
                    
//                    ProfileView(
//                        isShowingSignInView: $isShowingSignInView,
//                        viewModel: ProfileViewModel(authManager: authManager, userManager: userManager)
//                    )
                }
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