//
//  Cart.swift
//  AromiusGreen
//
//  Created by VictorZima on 20/09/2024.
//

import FirebaseFirestoreSwift

struct Cart: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String?
    var items: [CartItem]
    var selectedDeliveryMethod: String?
    var deliveryCost: Double?
    
    var totalAmount: Double {
        let itemTotal = items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        return itemTotal + (deliveryCost ?? 0.0)
    }
    
    var totalItems: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
}
