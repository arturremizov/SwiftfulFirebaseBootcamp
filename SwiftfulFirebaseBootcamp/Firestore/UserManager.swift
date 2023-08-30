//
//  UserManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 11.08.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct Movie: Codable {
    let id: String
    let title: String
    let isPopular: Bool
}

struct FavoriteProduct: Codable {
    let id: String
    let productId: Int
    let dateCreated: Timestamp
    
    init(id: String, productId: Int, dateCreated: Timestamp = Timestamp()) {
        self.id = id
        self.productId = productId
        self.dateCreated = dateCreated
    }
}

extension AppUser {
    init(authUser: AuthUser) {
        self.userId = authUser.uid
        self.isAnonymous = authUser.isAnonymous
        self.email = authUser.email
        self.photoUrl = authUser.photoUrl
        self.dateCreated = Timestamp().dateValue()
        self.isPremium = false
        self.preferences = nil
        self.favoriteMovie = nil
        self.profileImagePath = nil
        self.profileImageUrl = nil
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
    
    func updateUserProfileImage(userId: String, path: String?, url: String?) async throws {
        try await userDocument(userId: userId).updateData([
            "profile_image_path": path as Any,
            "profile_image_url": url as Any
        ])
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
    
    func addUserFavoriteProduct(userId: String, productId: Int) async throws {
        let document = userFavoriteProductCollection(userId: userId).document()
        let favProduct = FavoriteProduct(id: document.documentID, productId: productId)
        try document.setData(from: favProduct, merge: false, encoder: encoder)
    }
    
    func removeUserFavoriteProduct(userId: String, favoriteProductId: String) async throws {
        try await userFavoriteProductDocument(userId: userId, favoriteProductId: favoriteProductId).delete()
    }
    
    func getAllUserFavoriteProducts(userId: String,
                                    count: Int,
                                    lastDocument: DocumentSnapshot?) async throws -> (documents: [FavoriteProduct], lastDocument: DocumentSnapshot?) {
        
        var query = userFavoriteProductCollection(userId: userId)
            .limit(to: count)
        if let lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        return try await query.getDocuments(as: FavoriteProduct.self, decoder: decoder)
    }
    
    func addListenerForAllUserFavoriteProducts(userId: String) -> (publisher: AnyPublisher<[FavoriteProduct], Error>, listener: ListenerRegistration) {
        let publisher = PassthroughSubject<[FavoriteProduct], Error>()
        
        let listener = userFavoriteProductCollection(userId: userId).addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            guard let documents = snapshot?.documents else {
                print("No documents")
                return
            }
            
            snapshot?.documentChanges.forEach { change in
                if (change.type == .added) {
                    print("New products: \(change.document.data())")
                }
                if (change.type == .modified) {
                    print("Modified products: \(change.document.data())")
                }
                if (change.type == .removed) {
                    print("Removed products: \(change.document.data())")
                }
            }
            
            let favProducts = documents.compactMap { try? $0.data(as: FavoriteProduct.self, decoder: self.decoder) }
            publisher.send(favProducts)
        }
        return (publisher.eraseToAnyPublisher(), listener)
    }
    
    // MARK: - Helpers
    private func userDocument(userId: String) -> DocumentReference {
        return userCollection.document(userId)
    }
    
    private func userFavoriteProductCollection(userId: String) -> CollectionReference {
        return userDocument(userId: userId)
            .collection("favorite_products")
    }
    
    private func userFavoriteProductDocument(userId: String, favoriteProductId: String) -> DocumentReference {
        return userFavoriteProductCollection(userId: userId)
            .document(favoriteProductId)
    }
}
