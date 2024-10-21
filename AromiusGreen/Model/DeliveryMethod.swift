//
//  DeliveryMethod.swift
//  AromiusGreen
//
//  Created by VictorZima on 15/10/2024.
//

import FirebaseFirestoreSwift

struct DeliveryMethod: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var title: String
    var deliveryDescription: String
    var cost: Double
    
    enum CodingKeys: String, CodingKey {
        case title
        case deliveryDescription
        case cost
    }
}
