//
//  FavoritesView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 17.08.23.
//

import SwiftUI

struct FavoritesView: View {
    
    @StateObject var viewModel: FavoritesViewModel
    @State private var isDidAppear = false
    
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
            }
        }
        .navigationTitle("Favorites")
        .onFirstAppear {
            try? viewModel.getFavorites()
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
