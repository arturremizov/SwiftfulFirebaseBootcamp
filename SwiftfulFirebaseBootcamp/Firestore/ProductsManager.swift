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
        return try await productsCollection.getDocuments(as: Product.self, decoder: decoder)
    }
    
    func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
        return try await productsCollection.order(by: "price", descending: descending)
            .getDocuments(as: Product.self, decoder: decoder)
    }
    
    func getAllProductsFor(category: String) async throws -> [Product] {
        return try await productsCollection.whereField("category", isEqualTo: category)
            .getDocuments(as: Product.self, decoder: decoder)
    }
    
    func getAllProductsSortedByPriceFor(category: String, descending: Bool) async throws -> [Product] {
        return try await productsCollection
            .whereField("category", isEqualTo: category)
            .order(by: "price", descending: descending)
            .getDocuments(as: Product.self, decoder: decoder)
    }
    
    // MARK: - Helpers
    private func productDocument(productId: String) -> DocumentReference {
        return productsCollection.document(productId)
    }
}

extension Query {
    func getDocuments<T: Decodable>(as type: T.Type, decoder: Firestore.Decoder) async throws -> [T] {
        let snapshot = try await getDocuments()
        return try snapshot.documents.map { try $0.data(as: type, decoder: decoder) }
    }
}
