//
//  ProductsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 14.08.23.
//

import SwiftUI
import FirebaseFirestore

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

    private var lastDocument: DocumentSnapshot? = nil
    private(set) var isFetchingProducts: Bool = false
    
    private let productsManager: ProductsManager
    private let userManager: UserManager
    private let authManager: AuthenticationManager

    init(productsManager: ProductsManager, userManager: UserManager, authManager: AuthenticationManager) {
        self.productsManager = productsManager
        self.userManager = userManager
        self.authManager = authManager
    }
    
    func getProducts() async throws {
        isFetchingProducts = true
        try await filterProducts(by: selectedCategory, sortBy: selectedSortOption)
        isFetchingProducts = false

    }
    
    func sortProducts(_ sortOption: SortOption) async throws {
        self.selectedSortOption = sortOption
        self.products.removeAll()
        self.lastDocument = nil
        try await getProducts()
    }
    
    func filterProducts(by categoryOption: CategoryOption) async throws {
        self.selectedCategory = categoryOption
        self.products.removeAll()
        self.lastDocument = nil
        try await getProducts()
    }
    
    private func filterProducts(by category: CategoryOption, sortBy sortOption: SortOption) async throws {
        var filter: ProductsManager.Filter? = nil
        var sorter: ProductsManager.Sorter? = nil
        if let categoryId = category.id {
            filter = .isEqualTo(field: "category", value: categoryId)
        }
        if let isPriceDescending = sortOption.isPriceDescending {
            sorter = .order(by: "price", descending: isPriceDescending)
        }
        let (newProducts, newLastDocument) = try await productsManager.getAllProducts(filter: filter, sorter: sorter, count: 10, lastDocument: lastDocument)
        self.products.append(contentsOf: newProducts)
        if let newLastDocument {
            self.lastDocument = newLastDocument
        }
    }
    
    func getProductsCount() async throws {
        let count = try await productsManager.getAllProductsCount()
        print("ALL PRODUCT COUNT: \(count)")
    }
    
    func addUserFavoriteProduct(productId: Int) async throws {
        let authUser = try authManager.getAuthenticatedUser()
        try await userManager.addUserFavoriteProduct(userId: authUser.uid, productId: productId)
    }
//    func getProductsByRating() async throws {
//        let (newProducts, newLastDocument) = try await productsManager.getProductsByRating(count: 3, lastDocument: self.lastDocument)
//        self.products.append(contentsOf: newProducts)
//        self.lastDocument = newLastDocument
//    }
    
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
            ForEach(viewModel.products) { product in
                ProductCellView(product: product)
                    .contextMenu {
                        Button {
                            Task {
                                try? await viewModel.addUserFavoriteProduct(productId: product.id)
                            }
                        } label: {
                            HStack {
                                Text("Add to favorites")
                                Image(systemName: "star.fill")
                            }
                        }
                    }
                if product == viewModel.products.last {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 120)
                        .onAppear {
                            guard  !viewModel.isFetchingProducts else { return }
                            Task {
                                try await viewModel.getProducts()
                            }
                        }
                }
            }
        }
        .navigationTitle("Products")
        .task {
            try? await viewModel.getProducts()
            try? await viewModel.getProductsCount()
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
            ProductsView(
                viewModel: ProductsViewModel(productsManager: .init(),
                                             userManager: .init(),
                                             authManager: .init())
            )
        }
    }
}
