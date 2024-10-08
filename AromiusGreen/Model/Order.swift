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
    var status: String
    var createdAt: Date
    var deliveryMethod: String
    var updatedAt: Date?
    var statusHistory: [OrderStatusHistory] = []
    
    init(userId: String, items: [CartItem], totalAmount: Double, deliveryMethod: String) {
        self.userId = userId
        self.items = items
        self.totalAmount = totalAmount
        self.status = "Pending"
        self.createdAt = Date()
        self.deliveryMethod = deliveryMethod
    }
}

struct OrderStatusHistory: Codable {
    var status: String
    var date: Date
    
    init(status: String) {
        self.status = status
        self.date = Date()
    }
}
