//
//  UserManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 11.08.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AppUser: Codable {
    let userId: String
    let isAnonymous: Bool
    let email: String?
    let photoUrl: String?
    let dateCreated: Date
    let isPremium: Bool?
    
    init(userId: String, isAnonymous: Bool, email: String? = nil, photoUrl: String? = nil, dateCreated: Date, isPremium: Bool? = nil) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
    }
    
    init(authUser: AuthUser) {
        self.userId = authUser.uid
        self.isAnonymous = authUser.isAnonymous
        self.email = authUser.email
        self.photoUrl = authUser.photoUrl
        self.dateCreated = Timestamp().dateValue()
        self.isPremium = false
    }
    
    enum CodingKeys: CodingKey {
        case userId
        case isAnonymous
        case email
        case photoUrl
        case dateCreated
        case isPremium
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
    
    // MARK: - Helpers
    private func userDocument(userId: String) -> DocumentReference {
        return userCollection.document(userId)
    }
}
