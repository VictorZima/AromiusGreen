//
//  ProductView.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI

struct ProductView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var loadedImage: Image?
    var item: Product
    let baseUrl = "https://firebasestorage.googleapis.com/v0/b/aromius-ed523.appspot.com/o/"
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack {
                if item.image.isEmpty {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    let imagePath = "items_images%2F" + item.image.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                    let imageUrl = baseUrl + imagePath + "?alt=media"
                    if let loadedImage = loadedImage {
                        loadedImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .opacity(0.8)
                            .frame(width: 100, height: 100)
                            .onAppear {
                                Task {
                                    loadedImage = await ImageLoader.loadImage(from: URL(string: imageUrl)!)
                                }
                            }
                    }
//                    AsyncImage(url: URL(string: imageUrl)) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                    } placeholder: {
//                        Image(systemName: "photo")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .foregroundColor(.gray)
//                            .opacity(0.8)
//                            .frame(width: 100, height: 100)
//                    }
                }
                
                HStack(alignment: .center) {
                    Text("₪ ")
                        .font(.footnote)
                        .foregroundStyle(Color.black)
                    + Text("\(item.price)")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.black)
                    Spacer()
                    
                    Text("ml ")
                        .font(.footnote)
                        .foregroundStyle(Color.black)
                    + Text("\(item.value)")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.black)
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Text("\(item.name)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.black)
                
                VStack {
                    Text(item.descr)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.black)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .padding(.horizontal)
        }
    }
}

//#Preview {
//    ProductView(item: Product(name: "Face & eye cream serum For all skin types", descr: "This unique complex of Black pearl powder, seaweed & Dead Sea minerals produces a particularly concentrated cream serum that helps to improve the appearance of the skin’s tone and texture and improves the elasticity of the skin.  The serum penetrates into the deeper skin layers and works from the inside to delay the signs of aging.", value: "200 ml", category: [""], image: "462B9C3A-11F0-4A68-BB51-77131A2FE631.png", thumbnailImage: "", price: 50))
//
//        .environmentObject(DataManager())
//}

