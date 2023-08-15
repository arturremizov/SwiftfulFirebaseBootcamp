//
//  ProductsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 14.08.23.
//

import SwiftUI

@MainActor
final class ProductsViewModel: ObservableObject {
    
    enum SortOption: String, CaseIterable {
        case none
        case priceHigh
        case priceLow
        
        var isPriceDescending: Bool? {
            switch self {
            case .priceHigh:
                return true
            case .priceLow:
                return false
            default:
                return nil
            }
        }
    }
    
    enum CategoryOption: String, CaseIterable {
        case none
        case smartphones
        case laptops
        case fragrances
        
        var id: String? {
            switch self {
            case .none:
                return nil
            default:
                return rawValue
            }
        }
    }
    
    @Published private(set) var products: [Product] = []
    @Published var selectedSortOption: SortOption = .none
    @Published var selectedCategory: CategoryOption = .none

    private let productsManager: ProductsManager
    init(productsManager: ProductsManager) {
        self.productsManager = productsManager
    }
    
    func getAllProducts() async throws {
        self.products = try await productsManager.getAllProducts()
    }
    
    func sortProducts(_ sortOption: SortOption) async throws {
        self.selectedSortOption = sortOption
        try await filterProducts(by: selectedCategory, sortBy: sortOption)
    }
    
    func filterProducts(by categoryOption: CategoryOption) async throws {
        self.selectedCategory = categoryOption
        try await filterProducts(by: categoryOption, sortBy: selectedSortOption)
    }
    
    private func filterProducts(by category: CategoryOption, sortBy sortOption: SortOption) async throws {
        if let categoryId = category.id, let isPriceDescending = sortOption.isPriceDescending {
            self.products = try await productsManager.getAllProductsSortedByPriceFor(category: categoryId, descending: isPriceDescending)
        } else if let categoryId = category.id {
            self.products = try await productsManager.getAllProductsFor(category: categoryId)
        } else if let isPriceDescending = sortOption.isPriceDescending {
            self.products = try await productsManager.getAllProductsSortedByPrice(descending: isPriceDescending)
        } else {
            self.products = try await productsManager.getAllProducts()
        }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu("Sort: \(viewModel.selectedSortOption.rawValue)") {
                    ForEach(ProductsViewModel.SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.sortProducts(option)
                            }
                        }
                    }
                }
             }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Category: \(viewModel.selectedCategory.rawValue)") {
                    ForEach(ProductsViewModel.CategoryOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.filterProducts(by: option)
                            }
                        }
                    }
                }
            }
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
