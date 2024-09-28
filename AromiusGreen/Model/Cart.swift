//
//  Cart.swift
//  AromiusGreen
//
//  Created by VictorZima on 20/09/2024.
//

import Foundation

struct Cart: Identifiable {
    var id: UUID = UUID()
    var userId: String? // Может быть nil для гостевой корзины на будущее
    var items: [CartItem]
    
    var totalAmount: Double {
        return items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var totalItems: Int {
        return items.reduce(0) { $0 + $1.quantity }
    }
}
