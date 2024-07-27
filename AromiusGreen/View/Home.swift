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
            return dataManager.products.filter { $0.categories.contains(selectedCategory) }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
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
                        Image(systemName: "leaf")
                            .foregroundColor(.green)
                            .imageScale(.large)
                            .padding()
                            .frame(width: 50, height: 75)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke().opacity(0.2).foregroundColor(.green))
                    }
                    .padding(30)
                    
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
            ProductView(item: product)
        } label: {
            VStack(alignment: .leading) {
                let imagePath = "items_images%2Fthumbnails%2F" + product.thumbnailImage.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                let imageUrl = baseUrl + imagePath + "?alt=media"
                
                if let loadedImage = loadedImage {
                    loadedImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    //                            .background(.clear)
                        .background(Color.gray.opacity(0.075))
                        .frame(maxWidth: .infinity)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .opacity(0.8)
                        .background(Color.gray.opacity(0.075))
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
                        Text("₪ ")
                            .font(.footnote)
                            .foregroundStyle(Color.black)
                        + Text("\(product.price)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.black)
                    }
                    .padding(.top, 6)
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
