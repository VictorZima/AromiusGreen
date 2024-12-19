//
//  OrderStatus.swift
//  BattleGame
//
//  Created by VictorZima on 14/12/2024.
//

import Foundation

enum OrderStatus: Int, CaseIterable {
    case placed = 1
    case paid
    case processing
    case shipped
    case received

    var title: String {
        switch self {
        case .placed:
            return "order_status_placed"
        case .paid:
            return "Processing"
        case .processing:
            return "In Transit"
        case .shipped:
            return "Awaiting Pickup"
        case .received:
            return "Received"
        }
    }
}
