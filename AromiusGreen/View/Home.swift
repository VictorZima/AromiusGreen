//
//  Home.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI
import FirebaseStorage

struct Home: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var viewModel = HomeViewModel(dataManager: DataManager())
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 3, alignment: .leading), count: 2)
   
    var body: some View {
        NavigationView {
            if dataManager.isDataLoaded {
                contentView
            } else {
                ProgressView("...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    var CategoryListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.categories) { category in
                    Button {
                        viewModel.selectedCategory = category.id
                    } label: {
                        HStack {
                            if !category.icon.isEmpty {
                                Image(category.icon)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                            if viewModel.selectedCategory == category.id || category.id == "All" {
                                Text(category.title)
                            }
                        }
                        .frame(minWidth: 40, minHeight: 60)
                        .foregroundStyle(viewModel.selectedCategory == category.id ? .white : .darkBlueItem)
                        .padding(.horizontal, 10)
                        .background(viewModel.selectedCategory == category.id ? .black : .gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .onTapGesture {
                            withAnimation {
                                viewModel.selectedCategory = category.id
                            }
                        }
                    }
                }
            }
            .padding(.leading, 15)
            .onAppear {
                if viewModel.selectedCategory == nil {
                    viewModel.selectedCategory = "All"
                }
            }
        }
    }
    
    private var contentView: some View {
        VStack {
            headerView()
            
            ScrollView {
                VStack {
                    CategoryListView
                        .padding(.bottom)
                    
                    LazyVGrid(columns: columns, spacing: 3) {
                        ForEach(viewModel.filteredProducts, id: \.id) { item in
                            ProductCard(product: item)
                        }
                    }
                }
            }
        }
    }
    
    private func headerView() -> some View {
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
    }
}

struct ProductCard: View {
    @State private var loadedImage: Image?
    
    var product: Product
    let storageRef = Storage.storage().reference(withPath: "items_images/thumbnails/")
    
    var body: some View {
        NavigationLink {
            ProductView(passedProduct: product)
        } label: {
            VStack(alignment: .leading) {
                if let thumbnailImage = product.thumbnailImage {
                    let imagePath =  thumbnailImage.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                    let imageRef = storageRef.child(imagePath)
                    
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
                                loadImage(imageRef: imageRef)
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
                    
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("₪")
                            .font(.system(size: 12))
                        Text(product.price.formattedPrice())
                            .font(.system(size: 15))
                            .foregroundColor(Color.black)
                    }
                    .padding(.top, 10)
                    
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
    
    private func loadImage(imageRef: StorageReference) {
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Ошибка загрузки изображения: \(error.localizedDescription)")
                    return
                }
                if let url = url {
                    Task {
                        let image = await ImageLoader.loadImage(from: url)
                        DispatchQueue.main.async {
                            self.loadedImage = image
                        }
                    }
                }
            }
        }
}

//#Preview {
//    Home()
//        .environmentObject(DataManager())
//}
