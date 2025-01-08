//
//  Order.swift
//  AromiusGreen
//
//  Created by VictorZima on 01/10/2024.
//

import SwiftUI
import FirebaseFirestoreSwift

struct Order: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var items: [CartItem]
    var totalAmount: Double
    var status: OrderStatus
    var createdAt: Date
    var deliveryMethod: String
    var deliveryCost: Double
    var deliveryAddress: Address
    var updatedAt: Date?
    var statusHistory: [OrderStatusHistory] = []
    
    init(userId: String, items: [CartItem], totalAmount: Double, deliveryMethod: String, deliveryCost: Double, deliveryAddress: Address) {
        self.userId = userId
        self.items = items
        self.totalAmount = totalAmount
        self.status = .placed
        self.createdAt = Date()
        self.deliveryMethod = deliveryMethod
        self.deliveryCost = deliveryCost
        self.deliveryAddress = deliveryAddress
        self.statusHistory = [OrderStatusHistory(status: .placed)]
    }
}

struct OrderStatusHistory: Identifiable, Codable {
    var id: UUID = UUID()
    var status: OrderStatus
    var date: Date
    
    init(status: OrderStatus) {
        self.status = status
        self.date = Date()
    }
}
