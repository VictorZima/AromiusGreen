//
//  CartItemCellView.swift
//  AromiusGreen
//
//  Created by VictorZima on 26/09/2024.
//

import SwiftUI
import FirebaseStorage

struct CartItemCellView: View {
    let storageRef = Storage.storage().reference(withPath: "items_images/thumbnails/")
    var item: CartItem
    
    @EnvironmentObject var cartManager: CartManager
    @State private var loadedImage: Image?
    
    var body: some View {
        HStack(alignment: .top) {
            let imagePath = item.thumbnailImage.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            let imageRef = storageRef.child(imagePath)
            
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
                        imageRef.downloadURL { url, error in
                            if let error = error {
                                print("Ошибка загрузки изображения: \(error.localizedDescription)")
                                return
                            }
                            if let url = url {
                                Task {
                                    loadedImage = await ImageLoader.loadImage(from: url)
                                }
                            }
                        }
                    }
            }
            
            VStack(alignment: .leading) {
                Text(item.title)
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
            .padding(.trailing, 10)
            
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
        .padding(.leading, 7)
        .padding(.trailing, 17)
    }
}
