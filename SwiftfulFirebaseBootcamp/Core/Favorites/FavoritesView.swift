//
//  FavoritesView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 17.08.23.
//

import SwiftUI
import FirebaseFirestore

struct ProductContainer {
    let favoriteProduct: FavoriteProduct
    let product: Product
}

@MainActor
final class FavoritesViewModel: ObservableObject {
    
    @Published private(set) var products: [ProductContainer] = []
    private var lastDocument: DocumentSnapshot? = nil
    private(set) var isFetchingProducts: Bool = false
    @Published private(set) var isDidFetchAllItems: Bool = false

    private let userManager: UserManager
    private let authManager: AuthenticationManager
    private let productsManager: ProductsManager

    init(userManager: UserManager, authManager: AuthenticationManager, productsManager: ProductsManager) {
        self.userManager = userManager
        self.authManager = authManager
        self.productsManager = productsManager
    }

    func getFavorites(refresh: Bool = false) async throws {
        self.isFetchingProducts = true
        self.isDidFetchAllItems = false
        let authUser = try authManager.getAuthenticatedUser()
        let (favProducts, newLastDocument) = try await userManager.getAllUserFavoriteProducts(userId: authUser.uid, count: 6, lastDocument: refresh ? nil : lastDocument)
        if refresh {
            self.products.removeAll()
        }
        guard !favProducts.isEmpty else {
            self.isDidFetchAllItems = true
            self.isFetchingProducts = false
            return
        }
        
        let productIds = favProducts.map { $0.productId }
        
        let filter = ProductsManager.Filter.in(field: "id", value: productIds)
        let (products, _) = try await productsManager.getAllProducts(filter: filter, count: productIds.count)
        
        let newProductContainers: [ProductContainer] = favProducts.compactMap { favProduct in
            guard let product = products.first(where: { $0.id == favProduct.productId }) else {
                return nil
            }
            return ProductContainer(favoriteProduct: favProduct, product: product)
        }
        self.products.append(contentsOf: newProductContainers)
        
        if let newLastDocument {
            self.lastDocument = newLastDocument
        }
        self.isFetchingProducts = false
    }
    
    func removeFromFavorites(favoriteProductId: String) async throws {
        let authUser = try authManager.getAuthenticatedUser()
        try await userManager.removeUserFavoriteProduct(userId: authUser.uid, favoriteProductId: favoriteProductId)
        try await getFavorites(refresh: true)
    }
}

struct FavoritesView: View {
    
    @StateObject var viewModel: FavoritesViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.products, id: \.favoriteProduct.id.self) { container in
                ProductCellView(product: container.product)
                    .contextMenu {
                        Button(role: .destructive, action: {
                            Task {
                                try? await viewModel.removeFromFavorites(favoriteProductId: container.favoriteProduct.id)
                            }
                        }, label: {
                            HStack {
                                Text("Remove to favorites")
                                Image(systemName: "trash.fill")
                            }
                        })
                    }
                if !viewModel.isDidFetchAllItems && container.favoriteProduct.id == viewModel.products.last?.favoriteProduct.id {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 120)
                        .onAppear {
                            guard  !viewModel.isFetchingProducts else { return }
                            Task {
                                try await viewModel.getFavorites()
                            }
                        }
                }
            }
        }
        .navigationTitle("Favorites")
        .task {
            try? await viewModel.getFavorites(refresh: true)
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FavoritesView(
                viewModel: FavoritesViewModel(userManager: .init(),
                                              authManager: .init(),
                                              productsManager: .init()))
        }
    }
}
