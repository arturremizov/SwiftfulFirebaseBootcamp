//
//  TabbarView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 17.08.23.
//

import SwiftUI

struct TabbarView: View {
    
    @Binding var isShowingSignInView: Bool
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var productsManager: ProductsManager
    
    var body: some View {
        TabView {
            NavigationStack {
                ProductsView(
                    viewModel: ProductsViewModel(
                        productsManager: productsManager,
                        userManager: userManager,
                        authManager: authManager
                    )
                )
            }
            .tabItem {
                Image(systemName: "cart.fill")
                Text("Products")
            }
            
            NavigationStack {
                FavoritesView(
                    viewModel: FavoritesViewModel(userManager: userManager, authManager: authManager, productsManager: productsManager)
                )
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("Favorites")
            }
            
            NavigationStack {
                ProfileView(
                    isShowingSignInView: $isShowingSignInView,
                    viewModel: ProfileViewModel(authManager: authManager, userManager: userManager)
                )
            }
            .tabItem {
                Image(systemName: "person.crop.circle.fill")
                Text("Profile")
            }
        }
    }
}

struct TabbarView_Previews: PreviewProvider {
    static var previews: some View {
        TabbarView(isShowingSignInView: .constant(false))
            .environmentObject(AuthenticationManager())
            .environmentObject(UserManager())
            .environmentObject(ProductsManager())
    }
}
