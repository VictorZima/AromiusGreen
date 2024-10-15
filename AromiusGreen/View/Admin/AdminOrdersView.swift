//
//  AdminOrdersView.swift
//  AromiusGreen
//
//  Created by VictorZima on 07/10/2024.
//

import SwiftUI
import Firebase

struct AdminOrdersView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var isLoading: Bool = false
    @State private var orders: [Order] = []
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading orders...")
            } else if orders.isEmpty {
                Text("No orders found.")
                    .font(.title2)
                    .padding()
            } else {
                List(orders) { order in
                    AdminOrderRow(order: order)
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            isLoading = true
            dataManager.fetchAllOrders { fetchedOrders in
                self.orders = fetchedOrders
                isLoading = false
            }
        }
    }
}

struct AdminOrderRow: View {
    @State var order: Order
    @State private var isEditingStatus: Bool = false
    @State private var selectedStatus: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Amount: \(order.totalAmount.formattedPrice()) ₪")
            Text("Current Status: \(order.status)")
            Text("Last Updated: \(order.updatedAt?.formatted() ?? "N/A")")
            
            Button("Change Status") {
                isEditingStatus.toggle()
            }
            .sheet(isPresented: $isEditingStatus) {
                StatusChangeSheet(order: $order, selectedStatus: $selectedStatus)
            }
        }
        .padding()
        .cornerRadius(8)
    }
}

struct StatusChangeSheet: View {
    @Binding var order: Order
    @Binding var selectedStatus: String
    let statuses = ["Pending", "Shipped", "Delivered", "Cancelled"]
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack {
            Picker("Select Status", selection: $selectedStatus) {
                ForEach(statuses, id: \.self) { status in
                    Text(status)
                }
            }
            .pickerStyle(.wheel)
            
            Button("Save Status") {
                dataManager.updateOrderStatus(order: order, newStatus: selectedStatus)
            }
            .padding()
        }
    }
}

#Preview {
    AdminOrdersView()
}
