//
//  FavoritesView.swift
//  AromiusGreen
//
//  Created by VictorZima on 18/08/2024.
//

import SwiftUI
import FirebaseStorage

struct FavoritesView: View {
    @EnvironmentObject var viewModel: FavoritesViewModel
    @EnvironmentObject var authManager: AuthManager
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 3, alignment: .leading), count: 2)
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                headerView()
                
                if authManager.isUserAuthenticated {
                    if viewModel.favoriteProducts.isEmpty {
                        VStack {
                            Text("You have no favorite products yet.")
                                .font(.title2)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 3) {
                                ForEach(viewModel.favoriteProducts, id: \.id) { product in
                                    ProductCell(product: product, onRemove: { removedProduct in
                                        viewModel.favoriteProducts.removeAll { $0.id == removedProduct.id }
                                    })
                                }
                            }
                        }
                    }
                } else {
                    showAuthenticationPrompt()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            viewModel.fetchFavorites()
        }
        .sheet(isPresented: $viewModel.isShowingAuthView) {
            AuthView(isShowingAuthView: $viewModel.isShowingAuthView)
                .environmentObject(authManager)
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Text("favorites")
                .foregroundColor(.darkBlueItem)
                .font(.system(size: 20, weight: .bold))
            Spacer()
        }
        .padding(16)
    }
    
    private func showAuthenticationPrompt() -> some View {
            VStack(spacing: 20) {
                Text("Save your favorite products to favorites!")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()

                Text("Create an account or log in to save products to your favorites and easily find them later.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()

                Button {
                    viewModel.isShowingAuthView = true
                } label: {
                    Text("Sign in or Register")
                        .foregroundColor(.green)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 17)
                                .stroke(Color.green, lineWidth: 2)
                        )
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
}

struct ProductCell: View {
    @State private var loadedImage: Image?
    
    var product: FavoriteProduct
    let storageRef = Storage.storage().reference(withPath: "items_images/thumbnails/")
    let onRemove: (FavoriteProduct) -> Void
    
    var body: some View {
            NavigationLink {
                ProductView(productId: product.productId, onRemoveFromFavorites: {
                              onRemove(product)
                          })
            } label: {
                VStack(alignment: .leading) {                    
                    let imagePath = product.thumbnailImage.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                    let imageRef = storageRef.child(imagePath)
                    if let loadedImage = loadedImage {
                        loadedImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(.gray.opacity(0.075))
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(.gray.opacity(0.075))
                            .foregroundColor(.gray)
                            .opacity(0.8)
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
                    
                    VStack(alignment: .leading) {
                        Text("\(product.title)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(minHeight: 40, alignment: .topLeading)
                        
                        if let manufacturer = product.manufacturer {
                            Text("\(manufacturer.title)")
                                .font(.system(size: 15))
                                .foregroundColor(Color.gray)
                        }
                        
                        if let productLine = product.productLine {
                            Text("\(productLine.title)")
                                .font(.system(size: 13))
                                .foregroundColor(Color.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 15)
                }
                .frame(maxWidth: .infinity)
            }
    }
    
}
