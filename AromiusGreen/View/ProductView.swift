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
            
            VStack(alignment: .leading) {
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
                }
                    
                VStack(alignment: .leading) {
                    Text("\(item.name)")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.black)
                    Text("\(item.manufactureName)")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.gray)
                    Text("\(item.productLineName)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gray)
                }
//                .padding(.horizontal)
                
                HStack(alignment: .center) {
                    Text("₪ ")
                        .font(.footnote)
                        .foregroundStyle(Color.black)
                    + Text("\(item.price)")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.black)
                    Spacer()
                    
                    Text("\(item.value)")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.black)
                }
                .padding(.vertical)
                
                VStack(alignment: .leading) {
                    Text(item.descr)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.black)
                }
//                .padding(.horizontal)
            }
        }
        .padding()
        .navigationTitle(item.name)
    }
}

