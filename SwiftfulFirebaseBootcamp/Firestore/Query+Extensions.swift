//
//  Query+Extensions.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 20.08.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension Query {
    func getDocuments<T: Decodable>(as type: T.Type, decoder: Firestore.Decoder) async throws -> [T] {
        return try await getDocuments(as: type, decoder: decoder).documents
    }
    
    func getDocuments<T: Decodable>(as type: T.Type, decoder: Firestore.Decoder) async throws -> (documents: [T], lastDocument: DocumentSnapshot?) {
        let snapshot = try await getDocuments()
        let documents = try snapshot.documents.map { try $0.data(as: type, decoder: decoder) }
        return (documents, snapshot.documents.last)
    }
}
