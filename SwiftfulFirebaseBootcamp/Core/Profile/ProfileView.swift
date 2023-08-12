//
//  ProfileView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 11.08.23.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: AppUser? = nil
    
    private let authManager: AuthenticationManager
    private let userManager: UserManager
    init(authManager: AuthenticationManager, userManager: UserManager) {
        self.authManager = authManager
        self.userManager = userManager
    }
    
    func loadCurrentUser() async throws {
        let authUser = try authManager.getAuthenticatedUser()
        self.user = try await userManager.getUser(userId: authUser.uid)
    }
    
    func togglePremiumStatus() async throws {
        guard let user else { return }
        let isPremium = user.isPremium ?? false
        try await userManager.updateUserPremiumStatus(userId: user.userId, isPremium: !isPremium)
        self.user = try await userManager.getUser(userId: user.userId)
    }
}

struct ProfileView: View {
    
    @Binding var isShowingSignInView: Bool
    @StateObject var viewModel: ProfileViewModel
    @EnvironmentObject private var authManager: AuthenticationManager

    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                Text("Is Anonymous: \(user.isAnonymous.description.capitalized)")
                
                Button {
                    Task {
                        try await viewModel.togglePremiumStatus()
                    }
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
            }
            
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(
                        isShowingSignInView: $isShowingSignInView,
                        viewModel: SettingsViewModel(authManager: authManager)
                    )
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.headline)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(
                isShowingSignInView: .constant(false),
                viewModel: ProfileViewModel(authManager: .init(), userManager: .init())
            )
        }
        .environmentObject(AuthenticationManager())
    }
}
