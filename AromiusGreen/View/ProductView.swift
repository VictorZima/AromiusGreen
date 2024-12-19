//
//  ProductView.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI
import FirebaseStorage

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
    
    let storageRef = Storage.storage().reference(withPath: "items_images/")

    var body: some View {
        if let product = product {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack {
                        if let image = product.image {
                            let imagePath =  image.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                            let imageRef = storageRef.child(imagePath)
                            
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
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray.opacity(0.075))
                                .frame(maxWidth: .infinity)
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.title)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color.black)
                        
                        if let manufacturer = product.manufacturer {
                            HStack(alignment: .center, spacing: 8) {
                                Text(manufacturer.title)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if let productLine = product.productLine {
                            HStack(alignment: .center, spacing: 8) {
                                Text(productLine.title)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("₪")
                            .font(.system(size: 12))
                        Text(String(format: "%.2f", product.price))
                            .font(.system(size: 15))
                            .foregroundColor(Color.black)
                        Spacer()
                        
                        if let value = product.value, !value.isEmpty {
                            Text(value)
                                .font(.system(size: 15))
                                .foregroundColor(Color.black)
                        }
                    }
                    .padding(.vertical)
                    
                    VStack(alignment: .leading) {
                        if let description = product.productDescription, !description.isEmpty {
                            Text(description)
                                .font(.system(size: 15))
                                .foregroundColor(Color.black)
                        } else {
                            Text("Описание отсутствует.")
                                .font(.system(size: 15))
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    CustomActionButton(title: "Add to cart", widthSize: .large) {
                        if dataManager.currentUserId.isEmpty {
                            isShowingAuthView = true
                        } else {
                            cartManager.addToCart(product: product)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                }
            }
            .padding()
            .navigationTitle(product.title)
            .onAppear {
                if !dataManager.currentUserId.isEmpty {
                    checkIfFavorite()
                }
            }
            .sheet(isPresented: $isShowingAuthView) {
                AuthView(isShowingAuthView: $isShowingAuthView)
            }
        } else {
            Text("Loading product data...")
                .onAppear {
                    loadProductIfNeeded()
                }
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
        if dataManager.currentUserId.isEmpty {
            isShowingAuthView = true
            return
        }

        guard let product = product, let productId = product.id else {
            print("Ошибка: продукт не загружен или у него нет идентификатора")
            return
        }

        if isFavorite {
            dataManager.removeFromFavorites(productId: productId)
            onRemoveFromFavorites?()
        } else {
            dataManager.addToFavorites(product: product)
        }
        
        isFavorite.toggle()
    }
    
    func loadImage(from url: URL) async {
        if let image = await ImageLoader.loadImage(from: url) {
            DispatchQueue.main.async {
                self.loadedImage = image
            }
        }
    }
}
