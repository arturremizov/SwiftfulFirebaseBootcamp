//
//  AppUser.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 30.08.23.
//

import Foundation

struct AppUser: Codable {
    let userId: String
    let isAnonymous: Bool
    let email: String?
    let photoUrl: String?
    let dateCreated: Date
    let isPremium: Bool?
    let preferences: [String]?
    let favoriteMovie: Movie?
    let profileImageUrl: String?
    let profileImagePath: String?
    
    init(userId: String, isAnonymous: Bool, email: String? = nil, photoUrl: String? = nil, dateCreated: Date, isPremium: Bool? = nil, preferences: [String]? = nil, favoriteMovie: Movie? = nil, profileImageUrl: String? = nil, profileImagePath: String? = nil) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.preferences = preferences
        self.favoriteMovie = favoriteMovie
        self.profileImageUrl = profileImageUrl
        self.profileImagePath = profileImagePath
    }
}
