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
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(orders, id: \.id) { order in
                                OrderRow(order: order)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .fill(Color.white)
//                                            .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3)
//                                    )
//                                    .padding(.horizontal)
                                Divider()
                                    .padding(.leading, 14)
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
                VStack (alignment: .trailing) {
                    Text("Delivery Amount: \(order.deliveryCost.formattedPrice()) ₪")
                        .font(.subheadline)
                    Text("Total Amount: \(order.totalAmount.formattedPrice()) ₪")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
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
    @State private var loadedImage: Image?
    
    var body: some View {
        HStack {
            Text("\(index). \(item.title)")
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
            Text("Qty: \(item.quantity)")
                .font(.subheadline)
            Text("\(item.price.formattedPrice()) ₪")
                .font(.subheadline)
        }
    }
}

#Preview {
    OrdersView()
        .environmentObject(DataManager())
}
