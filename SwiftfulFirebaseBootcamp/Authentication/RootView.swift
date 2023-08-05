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
    
    var body: some View {
        ZStack {
            if !isShowingSignInView {
                NavigationStack {
                    SettingsView(
                        isShowingSignInView: $isShowingSignInView,
                        viewModel: SettingsViewModel(authManager: authManager)
                    )
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
                    viewModel: AuthenticationViewModel(authManager: authManager)
                )
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AuthenticationManager())
    }
}
