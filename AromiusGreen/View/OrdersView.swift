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
//            OrderProgressView(currentStatus: order.status)
            
            
            StatusProgressView(statuses: ["Placed", "Processing", "In Transit", "Awaiting Pickup", "Received"], currentStatus: order.status, statusHistory: order.statusHistory)
            
            Text("Items in this order:")
                .font(.headline)
                .padding(.top, 5)
            
            ForEach(order.items.indices, id: \.self) { index in
                OrderItemsRow(item: order.items[index], index: index + 1)
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
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(index).")
                .font(.footnote)
            
            Text(item.title)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            Spacer()
            
            Text("Qty: \(item.quantity)")
                .font(.subheadline)
            Text("\(item.price.formattedPrice()) ₪")
                .font(.subheadline)
        }
    }
}

struct StatusProgressView: View {
    let statuses: [String]
    let currentStatus: String
    let statusHistory: [OrderStatusHistory]
    
    var body: some View {
            
        HStack(alignment: .center, spacing: 5) {
                ForEach(0..<statuses.count, id: \.self) { index in
                    VStack(alignment: .center) {
                        Text(statuses[index])
                            .font(.caption)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                        
                        ZStack {
                            Circle()
                                .fill(isCompleted(index: index) ? Color.green : Color.gray)
                                .frame(width: 20, height: 20)
                            
                            Circle()
                                .fill(isCompleted(index: index) ? Color.green : Color.white)
                                .frame(width: 8, height: 8)
                            
                        }
                        
                        if let statusHistoryItem = getStatusHistory(for: statuses[index]) {
                            Text(statusHistoryItem.date, format: .dateTime.year().month().day())
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        } else {
                            Text("")
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                        
                    }
                    .opacity(isCompleted(index: index) ? 1 : 0.4)
                }
                
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100)
    }
    
    private func isCompleted(index: Int) -> Bool {
        guard let currentIndex = statuses.firstIndex(of: currentStatus) else { return false }
        
        return index <= currentIndex
    }
    
    private func getStatusHistory(for status: String) -> OrderStatusHistory? {
        return statusHistory.first { $0.status == status }
    }
}

//struct StatusProgressView: View {
//    let statuses: [String]
//    let currentStatus: String
//    let statusHistory: [OrderStatusHistory]
//    
//    var body: some View {
//        VStack {
//            ZStack {
//                HStack(spacing: 0) {
//                    ForEach(0..<statuses.count - 1, id: \.self) { index in
//                        Rectangle()
//                            .fill(isCompleted(index: index + 1) ? Color.green : Color.gray)
//                            .frame(height: 2)
//                        Spacer()
//                    }
//                }
//                .padding(.horizontal, 20)
////                .offset(y: 10)
//                
//                HStack(spacing: 0) {
//                    ForEach(0..<statuses.count, id: \.self) { index in
//                        VStack(spacing: 5) {
//                            Text(statuses[index])
//                                .font(.caption)
//                                .foregroundColor(.black)
//                                .lineLimit(1)
//                                .multilineTextAlignment(.center)
//                            
//                            ZStack {
//                                Circle()
//                                    .fill(isCompleted(index: index) ? Color.green : Color.gray)
//                                    .frame(width: 20, height: 20)
//                                
//                                Circle()
//                                    .fill(isCompleted(index: index) ? Color.green : Color.white)
//                                    .frame(width: 8, height: 8)
//                                
//                            }
//                            
//                            if let statusHistoryItem = getStatusHistory(for: statuses[index]) {
//                                Text(statusHistoryItem.date, format: .dateTime.year().month().day())
//                                    .font(.system(size: 8))
//                                    .foregroundColor(.gray)
//                            } else {
//                                Text("")
//                            }
//                        }
//                        
//                        if index != statuses.count - 1 {
//                            Spacer()
//                        }
//                    }
//                }
//            }
//        }
//        .padding(.horizontal)
//    }
//    
//    private func isCompleted(index: Int) -> Bool {
//        guard let currentIndex = statuses.firstIndex(of: currentStatus) else { return false }
//        
//        return index <= currentIndex
//    }
//    
//    private func getStatusHistory(for status: String) -> OrderStatusHistory? {
//        return statusHistory.first { $0.status == status }
//    }
//}

#Preview {
    OrdersView()
        .environmentObject(DataManager())
}
