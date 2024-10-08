//
//  FavoritesView.swift
//  AromiusGreen
//
//  Created by VictorZima on 18/08/2024.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    @State private var isShowingAuthView = false
    @State private var favoriteProducts: [FavoriteProduct] = []
    let baseUrl = "https://firebasestorage.googleapis.com/v0/b/aromius-ed523.appspot.com/o/"
    let columns = Array(repeating: GridItem(.flexible(), spacing: 3, alignment: .leading), count: 2)
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Favorites")
                        .foregroundColor(.darkBlueItem)
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                .padding(16)
                
                if authManager.isUserAuthenticated {
                    if favoriteProducts.isEmpty {
                        VStack {
                            Text("You have no favorite products yet.")
                                .font(.title2)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 3) {
                                ForEach(favoriteProducts, id: \.id) { product in
                                    ProductCell(product: product)
                                }
                            }
                        }
                    }
                } else {
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
                            isShowingAuthView = true
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            if authManager.isUserAuthenticated {
                dataManager.fetchFavorites { products in
                    favoriteProducts = products
                }
            }
        }
        .sheet(isPresented: $isShowingAuthView) {
            AuthView(isShowingAuthView: $isShowingAuthView)
                .environmentObject(authManager)
        }
    }
}

struct ProductCell: View {
    @State private var loadedImage: Image?
    var product: FavoriteProduct
    let baseUrl = "https://firebasestorage.googleapis.com/v0/b/aromius-ed523.appspot.com/o/"
    
    var body: some View {
        NavigationLink {
            ProductView(productId: product.id)
        } label: {
            VStack(alignment: .leading) {
                let imagePath = "items_images%2Fthumbnails%2F" + product.thumbnailImage.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                let imageUrl = baseUrl + imagePath + "?alt=media"
                
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
                            
                            Task {
                                loadedImage = await ImageLoader.loadImage(from: URL(string: imageUrl)!)
                            }
                        }
                }
                
                VStack(alignment: .leading) {
                    
                    Text("\(product.name)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: 40, alignment: .topLeading)
                    
                    Text("\(product.manufactureName)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gray)
                    
                    Text("\(product.productLineName)")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.gray)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
            }
            .frame(maxWidth: .infinity)
        }
        
    }
}

#Preview {
    FavoritesView()
        .environmentObject(AuthManager())
        .environmentObject(DataManager())
}
