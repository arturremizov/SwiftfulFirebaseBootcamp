//
//  StorageManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 28.08.23.
//

import Foundation
import FirebaseStorage

final class StorageManager: ObservableObject {
    
    private let storage = Storage.storage().reference()
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    private func userReference(userId: String) -> StorageReference {
        storage.child("users").child(userId)
    }
    private func storageReference(with path: String) -> StorageReference {
        Storage.storage().reference(withPath: path)
    }
    
    func saveImage(userId: String, data: Data) async throws -> (path: String, name: String) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let path = UUID().uuidString + ".jpeg"
        
        let returnedMetadata = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: metadata)
        guard let path = returnedMetadata.path, let name = returnedMetadata.name else {
            throw URLError(.badServerResponse)
        }
        return (path, name)
    }
    
    func deleteImage(path: String) async throws {
        try await storageReference(with: path).delete()
    }
    
    func getData(path: String) async throws -> Data {
        try await storage.child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
    func getURL(path: String) async throws -> URL {
        try await storageReference(with: path).downloadURL()
    }
}
