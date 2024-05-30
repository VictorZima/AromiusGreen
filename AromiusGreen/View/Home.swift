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

    var filteredProducts: [Product] {
           if selectedCategory == "0" {
               return dataManager.products
           } else {
               return dataManager.products.filter { $0.categories.contains(selectedCategory) }
           }
       }
    
    var body: some View {
        NavigationView {
            ScrollView() {
                VStack {
                    HStack {
                        Text("Dead Sea Cosmetics from **Aromius**")
                            .font(.system(size: 20))
                            .padding(.trailing)
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
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            ForEach(filteredProducts, id: \.id) { item in
                                ProductCard(product: item)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                }
            }
            .onAppear {
                if dataManager.products.isEmpty {
                    dataManager.fetchProducts()
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
                        .foregroundStyle(selectedCategory == category.id ? .white : .black)
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
            VStack {
                let imagePath = "items_images%2Fthumbnails%2F" + product.thumbnailImage.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                let imageUrl = baseUrl + imagePath + "?alt=media"
                if let loadedImage = loadedImage {
                    loadedImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(.clear)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .opacity(0.8)
                        .background(.clear)
                        .onAppear {
                            Task {
                                loadedImage = await ImageLoader.loadImage(from: URL(string: imageUrl)!)
                            }
                        }
                }
//                AsyncImage(url: URL(string: imageUrl)) { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .background(.clear)
//                } placeholder: {
//                    Image(systemName: "photo")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundColor(.gray)
//                        .opacity(0.8)
//                        .background(.clear)
//                }
                Spacer()
                Text("\(product.name)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.black)
                
                HStack(alignment: .center) {
                    Text("₪ ")
                        .font(.footnote)
                        .foregroundStyle(Color.black)
                    + Text("\(product.price)")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.black)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }
}

#Preview {
    Home()
        .environmentObject(DataManager())
}
