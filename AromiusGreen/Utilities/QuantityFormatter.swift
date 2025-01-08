//
//  QuantityFormatter.swift
//  AromiusGreen
//
//  Created by VictorZima on 04/01/2025.
//

import Foundation

extension Int {
    func formattedQuantity() -> String {
        return String(format: NSLocalizedString("order_quantity", comment: ""), self)
    }
}
