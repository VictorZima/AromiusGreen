//
//  CartItem.swift
//  AromiusGreen
//
//  Created by VictorZima on 20/09/2024.
//

import FirebaseFirestoreSwift

struct CartItem: Identifiable, Codable {
    @DocumentID var id: String?
    var productId: String
    var title: String
    var price: Double
    var quantity: Int
    var thumbnailImage: String
}
