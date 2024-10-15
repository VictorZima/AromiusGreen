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
    @State private var isShowingAuthView = false
    
    var passedProduct: Product?
    var productId: String?
    var onRemoveFromFavorites: (() -> Void)?
    let baseUrl = "https://firebasestorage.googleapis.com/v0/b/aromius-ed523.appspot.com/o/"
    
    var body: some View {
        Group {
            if let product = product {
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        ZStack {
                            if product.image.isEmpty {
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray.opacity(0.075))
                                    .frame(maxWidth: .infinity)
                            } else {
                                let imagePath = "items_images%2F" + (product.image.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
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
                                            if let url = URL(string: imageUrl) {
                                                Task {
                                                    loadedImage = await ImageLoader.loadImage(from: url)
                                                }
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
                            Text("\(product.title)")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color.black)
                            Text("\(product.manufactureName)")
                                .font(.system(size: 15))
                                .foregroundColor(Color.gray)
                            Text("\(product.productLineName)")
                                .font(.system(size: 13))
                                .foregroundColor(Color.gray)
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("₪")
                                .font(.system(size: 12))
                            Text(product.price.formattedPrice())
                                .font(.system(size: 15))
                                .foregroundColor(Color.black)
                            
                            Spacer()
                            
                            Text("\(product.value ?? "")")
                                .font(.system(size: 15))
                                .foregroundColor(Color.black)
                        }
                        .padding(.vertical)
                        
                        VStack(alignment: .leading) {
                            Text(product.descr)
                                .font(.system(size: 15))
                                .foregroundColor(Color.black)
                        }
                        
                        CustomButton(title: "Add to cart", widthSize: .large) {
                            if dataManager.currentUserId.isEmpty {
                                isShowingAuthView = true
                            } else {
                                cartManager.addToCart(product: product)
                            }
                        }
                        .padding(.bottom)
                    }
                }
                .padding()
                .navigationTitle(product.title)
            } else {
                Text("Loading product data...")
                    .onAppear {
                        loadProductIfNeeded()
                    }
            }
        }
        .onAppear {
            if !dataManager.currentUserId.isEmpty {
                checkIfFavorite()
            }
        }
        .sheet(isPresented: $isShowingAuthView) {
            AuthView(isShowingAuthView: $isShowingAuthView)
        }
    }
    
    func loadProductIfNeeded() {
        if let passedProduct = passedProduct {
            self.product = passedProduct
        } else if let productId = productId {
            dataManager.fetchProductById(productId: productId) { fetchedProduct in
                if let fetchedProduct = fetchedProduct {
                    self.product = fetchedProduct
                    checkIfFavorite()
                } else {
                    print("Продукт не найден")
                }
            }
        }
    }
    
    func checkIfFavorite() {
        guard let product = product, let productId = product.id else {
            print("Error: product is not loaded or has no ID")
            return
        }
        dataManager.isFavorite(productId: productId) { isFav in
            isFavorite = isFav
        }
    }

    func toggleFavorite() {
        // Проверка на авторизацию пользователя
        if dataManager.currentUserId.isEmpty {
            isShowingAuthView = true
            return
        }

        // Проверка, что продукт загружен и у него есть ID
        guard let product = product, let productId = product.id else {
            print("Ошибка: продукт не загружен или у него нет идентификатора")
            return
        }

        // Логика добавления/удаления из избранного
        if isFavorite {
            dataManager.removeFromFavorites(productId: productId)
            onRemoveFromFavorites?()
        } else {
            dataManager.addToFavorites(product: product)
        }
        
        // Обновляем статус
        isFavorite.toggle()
    }
}
