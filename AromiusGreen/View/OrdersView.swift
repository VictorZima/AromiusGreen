//
//  OrdersView.swift
//  AromiusGreen
//
//  Created by VictorZima on 02/10/2024.
//

import SwiftUI
import FirebaseStorage

struct OrdersView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthManager
    @State private var isLoading: Bool = false
    @State private var orders: [Order] = []
    
    var body: some View {
        VStack {
            if authManager.isUserAuthenticated {
                if isLoading {
                    ProgressView("Loading orders...")
                } else if orders.isEmpty {
                    Text("No orders found.")
                        .font(.title2)
                        .padding()
                } else {
//                    List(orders) { order in
//                        OrderRow(order: order)
//                    }
//                    .listStyle(PlainListStyle())
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(orders) { order in
                                OrderRow(order: order)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white)
                                            .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3)
                                    )
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            } else {
                Text("You need to sign in to see your orders.")
                    .font(.title2)
                    .padding()
            }
        }
        .onAppear {
            if authManager.isUserAuthenticated {
                dataManager.fetchOrders(for: dataManager.currentUserId) { orders in
                    self.orders = orders
                }
            }
        }
    }
}

struct OrderRow: View {
    var order: Order
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Status: \(order.status)")
            Text("Date: \(order.createdAt, format: .dateTime.year().month().day())")
            Text("Items in this order:")
                .font(.headline)
                .padding(.top, 5)
            
            ForEach(Array(order.items.enumerated()), id: \.element.id) { index, item in
                OrderItemsRow(item: item, index: index + 1)
            }
            
            HStack {
                Spacer()
                Text("Total Amount: \(order.totalAmount.formattedPrice()) ₪")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .padding(.top, 10)
        }
        .padding()
        .cornerRadius(10)
    }
}

struct OrderItemsRow: View {
    var item: CartItem
    var index: Int
    let storageRef = Storage.storage().reference(withPath: "items_images/thumbnails/")
    @State private var loadedImage: Image?
    
    var body: some View {
        HStack {
            Text("\(index). \(item.name)")
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
            Text("Qty: \(item.quantity)")
                .font(.subheadline)
            Text("\(item.price.formattedPrice()) ₪")
                .font(.subheadline)
            
            
//            Spacer()
            
//            let imageRef = storageRef.child(item.thumbnailImage)
//            
//            if let loadedImage = loadedImage {
//                loadedImage
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100)
//                    .background(.gray.opacity(0.075))
//            } else {
//                Image(systemName: "photo")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100)
//                    .background(.gray.opacity(0.075))
//                    .foregroundColor(.gray)
//                    .opacity(0.8)
//                    .onAppear {
//                        loadImage(from: imageRef)
//                    }
//            }
            
        }
    }
    
    func loadImage(from imageRef: StorageReference) {
        imageRef.downloadURL { url, error in
            if let url = url {
                Task {
                    loadedImage = await ImageLoader.loadImage(from: url)
                }
            } else {
                print("Error fetching image URL: \(error?.localizedDescription ?? "No error description")")
            }
        }
    }
}

#Preview {
    OrdersView()
        .environmentObject(DataManager())
}
