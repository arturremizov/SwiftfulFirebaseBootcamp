//
//  ProductsManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 14.08.23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProductsManager: ObservableObject {
    
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
    
    private let productsCollection =  Firestore.firestore().collection("products")

    func upload(_ product: Product) async throws {
        try productDocument(productId: String(product.id)).setData(from: product, merge: false, encoder: encoder)
    }

    func getAllProducts() async throws -> [Product] {
        let snapshot = try await productsCollection.getDocuments()
        return try snapshot.documents.map { try $0.data(as: Product.self, decoder: decoder) }
    }
    
    // MARK: - Helpers
    private func productDocument(productId: String) -> DocumentReference {
        return productsCollection.document(productId)
    }
}
