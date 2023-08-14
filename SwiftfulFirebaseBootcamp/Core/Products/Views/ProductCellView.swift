//
//  ProductCellView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Artur Remizov on 14.08.23.
//

import SwiftUI

struct ProductCellView: View {
    
    let product: Product
    
    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            let url = URL(string: product.thumbnail ?? "")
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(
                color: .black.opacity(0.2),
                radius: 6,
                x: 0,
                y: 2
            )
            
            VStack(alignment: .leading, spacing: 3.0) {
                Text(product.title ?? "n/a")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Price: $" + String(product.price ?? 0))
                Text("Rating: " + String(product.rating ?? 0))
                Text("Category: " + (product.category ?? "n/a"))
                Text("Brand: " + (product.brand ?? "n/a"))
            }
            .font(.callout)
            .foregroundColor(.secondary)
            .lineLimit(2)
        }
    }
}

struct ProductCellView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCellView(product: Product(id: 1, title: "Test", description: "test", price: 435, discountPercentage: 13464, rating: 5.00, stock: 124, brand: "brand-title", category: "category-title", thumbnail: "https://i.dummyjson.com/data/products/1/thumbnail.jpg", images: []))
    }
}
