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
    
    enum Filter {
        case isEqualTo(field: String, value: Any)
        case `in`(field: String, value: [Any])
    }
    
    enum Sorter {
        case order(by: String, descending: Bool)
    }
    
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
        try productDocument(productId: String(product.id))
            .setData(from: product, merge: false, encoder: encoder)
    }

    func getProduct(productId: String) async throws -> Product {
        try await productDocument(productId: productId)
            .getDocument(as: Product.self, decoder: decoder)
    }
    
    func getAllProducts(filter: Filter? = nil, sorter: Sorter? = nil, count: Int, lastDocument: DocumentSnapshot? = nil) async throws -> (documents: [Product], lastDocument: DocumentSnapshot?) {
        var query: Query = productsCollection
        if let filter {
            switch filter {
            case let .isEqualTo(field, value):
                query = query.whereField(field, isEqualTo: value)
            case let .in(field, value):
                query = query.whereField(field, in: value)
            }
        }
        if let sorter {
            switch sorter {
            case let .order(by, descending):
                query = query.order(by: by, descending: descending)
            }
        }
        if let lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        return try await query
            .limit(to: count)
            .getDocuments(as: Product.self, decoder: decoder)
    }
    
    func getProductsByRating(count: Int, lastDocument: DocumentSnapshot?) async throws -> (documents: [Product], lastDocument: DocumentSnapshot?) {
        var query = productsCollection
            .order(by: "rating", descending: true)
            .limit(to: count)
        
        if let lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        return try await query.getDocuments(as: Product.self, decoder: decoder)
    }
    
    func getAllProductsCount() async throws -> Int {
        try await productsCollection
            .count
            .getAggregation(source: .server)
            .count
            .intValue
    }
    
    // MARK: - Helpers
    private func productDocument(productId: String) -> DocumentReference {
        return productsCollection.document(productId)
    }
}
