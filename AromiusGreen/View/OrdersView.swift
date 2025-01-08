//
//  OrdersView.swift
//  AromiusGreen
//
//  Created by VictorZima on 02/10/2024.
//

import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthManager
    @State private var isLoading: Bool = false
    @State private var orders: [Order] = []
    
    var body: some View {
        VStack {
            if authManager.isUserAuthenticated {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(orders, id: \.id) { order in
                            OrderRow(order: order)
                            Divider()
                                .padding(.leading, 14)
                        }
                    }
                }
            } else {
                Text("order_need_signin")
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
            OrderProgressView(
                currentStatus: order.status,
                statusHistory: order.statusHistory
            )
            .padding(.horizontal, 10)
            
            Text("order_items_in_order")
                .font(.headline)
                .padding(.top, 5)
            
            ForEach(order.items.indices, id: \.self) { index in
                OrderItemsRow(item: order.items[index], index: index + 1)
            }
            
            HStack {
                Spacer()
                
                VStack (alignment: .trailing) {
                    Text(String(format: NSLocalizedString("order_delivery_amount", comment: ""), order.deliveryCost.formattedPrice()))
                        .font(.subheadline)

                    Text(String(format: NSLocalizedString("order_total_amount", comment: ""), order.totalAmount.formattedPrice()))
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
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(index).")
                .font(.footnote)
            
            Text(item.title)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            Spacer()
            
            Text(item.quantity.formattedQuantity())
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
