//
//  UserManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 11.08.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Movie: Codable {
    let id: String
    let title: String
    let isPopular: Bool
}

struct AppUser: Codable {
    let userId: String
    let isAnonymous: Bool
    let email: String?
    let photoUrl: String?
    let dateCreated: Date
    let isPremium: Bool?
    let preferences: [String]?
    let favoriteMovie: Movie?
    
    init(userId: String, isAnonymous: Bool, email: String? = nil, photoUrl: String? = nil, dateCreated: Date, isPremium: Bool? = nil, preferences: [String]? = nil, favoriteMovie: Movie? = nil) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.preferences = preferences
        self.favoriteMovie = favoriteMovie
    }
    
    init(authUser: AuthUser) {
        self.userId = authUser.uid
        self.isAnonymous = authUser.isAnonymous
        self.email = authUser.email
        self.photoUrl = authUser.photoUrl
        self.dateCreated = Timestamp().dateValue()
        self.isPremium = false
        self.preferences = nil
        self.favoriteMovie = nil
    }
}

final class UserManager: ObservableObject {
    
    private var encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private var decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private let userCollection =  Firestore.firestore().collection("users")
    
    func createNewUser(_ user: AppUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    
    func getUser(userId: String) async throws -> AppUser {
        try await userDocument(userId: userId).getDocument(as: AppUser.self, decoder: decoder)
    }
    
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        try await userDocument(userId: userId).updateData(["is_premium": isPremium])
    }
    
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String: Any] = [
            "preferences": FieldValue.arrayUnion([preference])
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String: Any] = [
            "preferences": FieldValue.arrayRemove([preference])
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func addFavoriteMovie(userId: String, movie: Movie) async throws {
        let data: [String: Any] = [
            "favorite_movie": try encoder.encode(movie)
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    func removeFavoriteMovie(userId: String) async throws {
        let data: [String: Any?] = [
            "favorite_movie": nil
        ]
        try await userDocument(userId: userId).updateData(data as [AnyHashable : Any])
    }
    
    // MARK: - Helpers
    private func userDocument(userId: String) -> DocumentReference {
        return userCollection.document(userId)
    }
}
