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
    var deliveryCost: Double
    var updatedAt: Date?
    var statusHistory: [OrderStatusHistory] = []
    
    init(userId: String, items: [CartItem], totalAmount: Double, deliveryMethod: String, deliveryCost: Double) {
        self.userId = userId
        self.items = items
        self.totalAmount = totalAmount
        self.status = "Pending"
        self.createdAt = Date()
        self.deliveryMethod = deliveryMethod
        self.deliveryCost = deliveryCost
    }
    
    enum CodingKeys: String, CodingKey {
        case userId
        case items
        case totalAmount
        case status
        case createdAt
        case deliveryMethod
        case deliveryCost
        case updatedAt
        case statusHistory
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
