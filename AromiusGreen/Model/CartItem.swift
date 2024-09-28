//
//  CartItem.swift
//  AromiusGreen
//
//  Created by VictorZima on 20/09/2024.
//

import Foundation

struct CartItem: Identifiable {
    var id: UUID = UUID()
    var productId: UUID
    var name: String
    var price: Double
    var quantity: Int
    var thumbnailImage: String
}
