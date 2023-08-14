//
//  ProductsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 14.08.23.
//

import SwiftUI

@MainActor
final class ProductsViewModel: ObservableObject {
    
    @Published private(set) var products: [Product] = []
    
    private let productsManager: ProductsManager
    init(productsManager: ProductsManager) {
        self.productsManager = productsManager
    }
    
    func getAllProducts() async throws {
        self.products = try await productsManager.getAllProducts()
    }
    
//    func downloadProductsAndUploadToFirebase() {
//        let url = URL(string: "https://dummyjson.com/products")!
//        Task {
//            do {
//                let (data, _) = try await URLSession.shared.data(from: url)
//                let produtsResult = try JSONDecoder().decode(ProductArray.self, from: data)
//                for product in produtsResult.products {
//                    try await productsManager.upload(product)
//                }
//                print("Did upload products to Firebase.")
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
}

struct ProductsView: View {
    
    @StateObject var viewModel: ProductsViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.products) {
                ProductCellView(product: $0)
            }
        }
        .navigationTitle("Products")
        .task {
            try? await viewModel.getAllProducts()
        }
    }
}

struct ProductsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductsView(viewModel: ProductsViewModel(productsManager: .init()))
        }
    }
}
