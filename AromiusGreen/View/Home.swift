//
//  Home.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedCategory = "0"
    let columns = Array(repeating: GridItem(.flexible(), spacing: 3, alignment: .leading), count: 2)
    
    var filteredProducts: [Product] {
        if selectedCategory == "0" {
            return dataManager.products
        } else {
            return dataManager.products.filter { $0.categoryIds.contains(selectedCategory) }
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
                            if selectedCategory == category.id || category.id == "0" {
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
        }
    }
}

struct ProductCard: View {
    @State private var loadedImage: Image?
    var product: Product
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
                    if product.productLineId != 0 {
                        Text("\(product.productLineName)")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.gray)
                    } else {
                        Text(" ")
                            .font(.system(size: 10))
                    }

                    HStack(alignment: .center) {
                        if product.price.truncatingRemainder(dividingBy: 1) == 0 {
                            Text("₪ \(Int(product.price))")
                                .font(.system(size: 15))
                                .foregroundColor(Color.black)
                        } else {
                            let priceComponents = String(format: "%.2f", product.price).split(separator: ".")

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
