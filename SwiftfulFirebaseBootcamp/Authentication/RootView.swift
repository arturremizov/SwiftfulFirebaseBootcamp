//
//  RootView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 3.08.23.
//

import SwiftUI

struct RootView: View {
    
    @State private var isShowingSignInView: Bool = false
    
    private let authManager: AuthenticationManager
    init(authManager: AuthenticationManager = .shared) {
        self.authManager = authManager
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                SettingsView(isShowingSignInView: $isShowingSignInView)
            }
        }
        .onAppear {
            let user = try? authManager.getAuthenticatedUser()
            isShowingSignInView = user == nil
        }
        .fullScreenCover(isPresented: $isShowingSignInView) {
            NavigationStack {
                AuthenticationView(isShowingSignInView: $isShowingSignInView)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
