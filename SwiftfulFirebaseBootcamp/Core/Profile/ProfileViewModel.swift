//
//  ProfileViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 28.08.23.
//

import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: AppUser? = nil
    let preferences: [String] = ["Sports", "Movies", "Books"]
    @Published var selectedPhotoItem: PhotosPickerItem? = nil

    private let authManager: AuthenticationManager
    private let userManager: UserManager
    private let storageManager: StorageManager
    init(authManager: AuthenticationManager, userManager: UserManager, storageManager: StorageManager) {
        self.authManager = authManager
        self.userManager = userManager
        self.storageManager = storageManager
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
    
    func saveProfileImage(item: PhotosPickerItem) async throws {
        guard let user else { return }
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw URLError(.cannotDecodeRawData)
        }
        let (path, name) = try await storageManager.saveImage(userId: user.userId, data: data)
        print("Did upldad image with name: \(name), path: \(path)")
        let url = try await storageManager.getURL(path: path)
        try await userManager.updateUserProfileImage(userId: user.userId, path: path, url: url.absoluteString)
    }
    
    func deleteProfileImage() async throws  {
        guard let user, let path = user.profileImagePath else { return }
        try await storageManager.deleteImage(path: path)
        try await userManager.updateUserProfileImage(userId: user.userId, path: nil, url: nil)
    }
}
