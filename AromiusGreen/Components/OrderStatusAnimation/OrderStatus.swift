//
//  OrderStatus.swift
//  BattleGame
//
//  Created by VictorZima on 14/12/2024.
//

import Foundation

enum OrderStatus: Int, CaseIterable, Comparable, Codable, Identifiable {
    case placed = 1
    case paid
    case processing
    case shipped
    case received
    
    var id: Int { self.rawValue }
    
    // Локализованное название статуса
    var displayName: String {
        NSLocalizedString("status.\(self.rawValue)", comment: "")
    }
    
    // Сравнение для определения порядка статусов
    static func < (lhs: OrderStatus, rhs: OrderStatus) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

//enum OrderStatus: String, CaseIterable, Comparable {
//    case placed = "Placed"
//    case paid = "Paid"
//    case processing = "Processing"
//    case shipped = "Shipped"
//    case received = "Received"
//    
//    var title: String {
//        switch self {
//        case .placed:
//            return "Placed"
//        case .paid:
//            return "Paid"
//        case .processing:
//            return "Processing"
//        case .shipped:
//            return "Shipped"
//        case .received:
//            return "Received"
//        }
//    }
//    
//    // Сравнение для определения порядка статусов
//    static func < (lhs: OrderStatus, rhs: OrderStatus) -> Bool {
//        return lhs.order < rhs.order
//    }
//    
//    var order: Int {
//        switch self {
//        case .placed:
//            return 1
//        case .paid:
//            return 2
//        case .processing:
//            return 3
//        case .shipped:
//            return 4
//        case .received:
//            return 5
//        }
//    }
//}
