//
//  CartItemCellView.swift
//  AromiusGreen
//
//  Created by VictorZima on 26/09/2024.
//

import SwiftUI

struct CartItemCellView: View {
    @EnvironmentObject var cartManager: CartManager
    var item: CartItem
    let baseUrl = "https://firebasestorage.googleapis.com/v0/b/aromius-ed523.appspot.com/o/"
    @State private var loadedImage: Image?
    
    var body: some View {
        HStack(alignment: .top) {
            let imagePath = "items_images%2Fthumbnails%2F" + item.thumbnailImage.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            let imageUrl = baseUrl + imagePath + "?alt=media"
            
            if let loadedImage = loadedImage {
                loadedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .background(.gray.opacity(0.075))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .background(.gray.opacity(0.075))
                    .foregroundColor(.gray)
                    .opacity(0.8)
                    .onAppear {
                        Task {
                            loadedImage = await ImageLoader.loadImage(from: URL(string: imageUrl)!)
                        }
                    }
            }
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Text("\(item.price.formattedPrice()) ₽")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                HStack {
                    Button {
                        cartManager.decreaseQuantity(of: item.productId)
                    } label: {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Text("\(item.quantity)")
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                    Button {
                        cartManager.increaseQuantity(of: item.productId)
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            
            VStack {
                Spacer()
                Button {
                    cartManager.removeFromCart(productId: item.productId)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                Spacer()
            }
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 7)

    }
}
