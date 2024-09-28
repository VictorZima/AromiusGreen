//
//  ProductView.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI

struct ProductView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var cartManager: CartManager
    @Environment(\.presentationMode) var presentationMode
    @State private var product: Product?
    @State private var loadedImage: Image?
    @State private var isFavorite = false
    var productId: UUID
    let baseUrl = "https://firebasestorage.googleapis.com/v0/b/aromius-ed523.appspot.com/o/"
    
    var body: some View {
        Group {
            if let item = product {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        ZStack {
                            if item.image.isEmpty {
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray.opacity(0.075))
                                    .frame(maxWidth: .infinity)
                            } else {
                                let imagePath = "items_images%2F" + item.image.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                                let imageUrl = baseUrl + imagePath + "?alt=media"
                                if let loadedImage = loadedImage {
                                    loadedImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .background(.gray.opacity(0.075))
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.gray.opacity(0.075))
                                        .frame(maxWidth: .infinity)
                                        .onAppear {
                                            Task {
                                                loadedImage = await ImageLoader.loadImage(from: URL(string: imageUrl)!)
                                            }
                                        }
                                }
                            }
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    Button {
                                        toggleFavorite()
                                    } label: {
                                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                                            .foregroundColor(isFavorite ? .red : .white)
                                            .padding()
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                }
                                Spacer()
                            }
                            .padding([.top, .trailing], 10)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading) {
                            Text("\(item.name)")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color.black)
                            Text("\(item.manufactureName)")
                                .font(.system(size: 15))
                                .foregroundColor(Color.gray)
                            Text("\(item.productLineName)")
                                .font(.system(size: 13))
                                .foregroundColor(Color.gray)
                        }
                        
                        HStack(alignment: .center) {
                            if item.price.truncatingRemainder(dividingBy: 1) == 0 {
                                Text("₪ \(Int(item.price))")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.black)
                            } else {
                                let priceComponents = String(format: "%.2f", item.price).split(separator: ".")

                                HStack(alignment: .top, spacing: 0) {
                                    Text("₪ \(priceComponents[0])")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.black)
                                    
                                    Text("\(priceComponents[1])")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.gray)
                                        .baselineOffset(15)
                                        .overlay(
                                            Rectangle()
                                                .frame(height: 1)
                                                .offset(y: -15),
                                            alignment: .bottom
                                        )
                                        .foregroundStyle(Color.gray)
                                        .offset(y: -7)
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(item.value)")
                                .font(.system(size: 15))
                                .foregroundColor(Color.black)
                        }
                        .padding(.vertical)
                        
                        VStack(alignment: .leading) {
                            Text(item.descr)
                                .font(.system(size: 15))
                                .foregroundColor(Color.black)
                        }
                        
                        Button {
                            cartManager.addToCart(product: item)
                        } label: {
                            HStack {
                                Image(systemName: "cart")
                                    .font(.title)
                                    .foregroundStyle(Color.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(.black)
                            .cornerRadius(7)
                            .padding()
                        }
                        
                    }
                }
                .padding()
                .navigationTitle(item.name)
            } else {
                ProgressView("Loading product details...")
                    .onAppear {
                        loadProductData()
                    }
            }
        }
        .onAppear {
            if dataManager.currentUserId.isEmpty == false {
                checkIfFavorite()
            }
        }
    }
    
    func loadProductData() {
        dataManager.fetchProductById(productId: productId) { fetchedProduct in
            if let fetchedProduct = fetchedProduct {
                print("Product fetched: \(fetchedProduct.name)")
                self.product = fetchedProduct
            } else {
                print("Product id: \(productId) not found or error occurred")
            }
        }
    }
    
    func checkIfFavorite() {
        dataManager.isFavorite(productId: productId.uuidString) { isFav in
            isFavorite = isFav
        }
    }
    
    func toggleFavorite() {
        guard let item = product else { return }
        if isFavorite {
            dataManager.removeFromFavorites(productId: item.id)
        } else {
            dataManager.addToFavorites(product: item)
        }
        isFavorite.toggle()
    }
}
