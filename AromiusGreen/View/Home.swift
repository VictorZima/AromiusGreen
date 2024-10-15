//
//  Home.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedCategory: String? = nil
    let columns = Array(repeating: GridItem(.flexible(), spacing: 3, alignment: .leading), count: 2)
    
    var filteredProducts: [Product] {
        if selectedCategory == "All" || selectedCategory == nil {
            return dataManager.products
        } else if let selectedCategory = selectedCategory {
            return dataManager.products.filter { $0.categoryIds.contains(selectedCategory) }
        } else {
            return []
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Dead Sea Cosmetics\nfrom")
                        .font(.system(size: 18))
                    + Text(" AROMIUS")
                        .foregroundColor(.darkBlueItem)
                        .font(.system(size: 20, weight: .bold))
                    + Text(" shop")
                        .font(.system(size: 18))
                    Spacer()
                }
                .padding(16)
                
                ScrollView {
                    VStack {
                        CategoryListView
                            .padding(.bottom)
                        
                        LazyVGrid(columns: columns, spacing: 3) {
                            ForEach(filteredProducts, id: \.id) { item in
                                ProductCard(product: item)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var CategoryListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(dataManager.categories) { category in
                    Button {
                        selectedCategory = category.id
                    } label: {
                        HStack {
                            if !category.icon.isEmpty {
                                Image(category.icon)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                            if selectedCategory == category.id || category.id == "All" {
                                Text(category.title)
                            }
                        }
                        .frame(minWidth: 40, minHeight: 60)
                        .foregroundStyle(selectedCategory == category.id ? .white : .darkBlueItem)
                        .padding(.horizontal, 10)
                        .background(selectedCategory == category.id ? .black : .gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .onTapGesture {
                            withAnimation {
                                selectedCategory = category.id
                            }
                        }
                    }
                }
            }
            .padding(.leading, 15)
            .onAppear {
                if selectedCategory == nil {
                    selectedCategory = "All"
                }
            }
        }
    }
}

struct ProductCard: View {
    @State private var loadedImage: Image?
    var product: Product
    let baseUrl = "https://firebasestorage.googleapis.com/v0/b/aromius-ed523.appspot.com/o/"
    
    var body: some View {
        NavigationLink {
            ProductView(passedProduct: product)
        } label: {
            VStack(alignment: .leading) {
                
                let thumbnailImage = product.thumbnailImage
                
                if let encodedThumbnail = thumbnailImage.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                   let url = URL(string: baseUrl + "items_images%2Fthumbnails%2F" + encodedThumbnail + "?alt=media") {
                    
                    if let loadedImage = loadedImage {
                        loadedImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(Color.gray.opacity(0.075))
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(Color.gray.opacity(0.075))
                            .foregroundColor(.gray)
                            .opacity(0.8)
                            .frame(maxWidth: .infinity)
                            .onAppear {
                                Task {
                                    loadedImage = await ImageLoader.loadImage(from: url)
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
                    
                    Text("\(product.manufactureName)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gray)
                    Text(product.productLineName)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.gray)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("₪")
                            .font(.system(size: 12))
                        Text(product.price.formattedPrice())
                            .font(.system(size: 15))
                            .foregroundColor(Color.black)
                    }
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    Home()
        .environmentObject(DataManager())
}
