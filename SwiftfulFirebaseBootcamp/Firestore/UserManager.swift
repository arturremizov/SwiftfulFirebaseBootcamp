//
//  UserManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 11.08.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AppUser: Decodable {
    let userId: String
    let isAnonymous: Bool
    let email: String?
    let photoUrl: String?
    let dateCreated: Date
}

final class UserManager: ObservableObject {
    
    private var decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createNewUser(authUser: AuthUser) async throws {
        var userData: [String : Any] = [
            "user_id": authUser.uid,
            "is_anonymous": authUser.isAnonymous,
            "date_created": Timestamp(),
        ]
        
        if let email = authUser.email {
            userData["email"] = email
        }
        if let photoUrl = authUser.photoUrl {
            userData["photo_url"] = photoUrl
        }
        
        try await Firestore.firestore()
            .collection("users")
            .document(authUser.uid)
            .setData(userData, merge: false)
    }
    
    func getUser(userId: String) async throws -> AppUser {
        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .getDocument(as: AppUser.self, decoder: decoder)
    }
}
