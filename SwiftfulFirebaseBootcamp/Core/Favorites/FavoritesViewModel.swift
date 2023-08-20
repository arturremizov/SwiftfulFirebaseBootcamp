//
//  FavoritesViewModel.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 20.08.23.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct ProductContainer {
    let favoriteProduct: FavoriteProduct
    let product: Product
}

@MainActor
final class FavoritesViewModel: ObservableObject {
    
    @Published private(set) var products: [ProductContainer] = []
    private var subscriptions: [AnyCancellable] = []
    private var listener: ListenerRegistration? = nil

    private let userManager: UserManager
    private let authManager: AuthenticationManager
    private let productsManager: ProductsManager

    init(userManager: UserManager, authManager: AuthenticationManager, productsManager: ProductsManager) {
        self.userManager = userManager
        self.authManager = authManager
        self.productsManager = productsManager
    }

    func getFavorites() throws {
        let authUser = try authManager.getAuthenticatedUser()
        let (publisher, listener) = userManager.addListenerForAllUserFavoriteProducts(userId: authUser.uid)
        publisher.sink { completion in
            
        } receiveValue: { [weak self] favProducts in
            self?.getProducts(for: favProducts)
        }
        .store(in: &subscriptions)
        self.listener = listener
    }
    
    func removeFromFavorites(favoriteProductId: String) async throws {
        let authUser = try authManager.getAuthenticatedUser()
        try await userManager.removeUserFavoriteProduct(userId: authUser.uid, favoriteProductId: favoriteProductId)
    }
    
    // MARK: - Helpers
    private func getProducts(for favProducts: [FavoriteProduct]) {
        guard !favProducts.isEmpty else {
            return
        }

        let productIds = favProducts.map { $0.productId }

        let filter = ProductsManager.Filter.in(field: "id", value: productIds)
        Task {
            let (products, _) = try await self.productsManager.getAllProducts(filter: filter, count: productIds.count)

            let newProductContainers: [ProductContainer] = favProducts.compactMap { favProduct in
                guard let product = products.first(where: { $0.id == favProduct.productId }) else {
                    return nil
                }
                return ProductContainer(favoriteProduct: favProduct, product: product)
            }
            self.products = newProductContainers
        }
    }
}
