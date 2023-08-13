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
    let preferences: [String] = ["Sports", "Movies", "Books"]
    
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
    
    func addUserPreference(_ preference: String) async throws {
        guard let user else { return }
        try await userManager.addUserPreference(userId: user.userId, preference: preference)
        self.user = try await userManager.getUser(userId: user.userId)
    }
    
    func removeUserPreference(_ preference: String) async throws {
        guard let user else { return }
        try await userManager.removeUserPreference(userId: user.userId, preference: preference)
        self.user = try await userManager.getUser(userId: user.userId)
    }
    
    func addFavoriteMovie() async throws {
        guard let user else { return }
        let movie = Movie(id: "1", title: "Avatar 2", isPopular: true)
        try await userManager.addFavoriteMovie(userId: user.userId, movie: movie)
        self.user = try await userManager.getUser(userId: user.userId)
    }
    
    func removeFavoriteMovie() async throws {
        guard let user else { return }
        try await userManager.removeFavoriteMovie(userId: user.userId)
        self.user = try await userManager.getUser(userId: user.userId)
    }
    
    func preferenceIsSelected(_ preference: String) -> Bool {
        user?.preferences?.contains(preference) == true
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
                
                VStack {
                    HStack {
                        ForEach(viewModel.preferences, id: \.self) { preference in
                            Button(preference) {
                                Task {
                                    if viewModel.preferenceIsSelected(preference) {
                                        try await viewModel.removeUserPreference(preference)
                                    } else {
                                        try await viewModel.addUserPreference(preference)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .font(.headline)
                            .tint(viewModel.preferenceIsSelected(preference) ? .green : .gray)
                        }
                    }
                    
                    Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    Task {
                        if viewModel.user?.favoriteMovie == nil {
                            try await viewModel.addFavoriteMovie()
                        } else {
                            try await viewModel.removeFavoriteMovie()
                        }
                    }
                } label: {
                    Text("Favorite Movie: \(user.favoriteMovie?.title ?? "")")
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
