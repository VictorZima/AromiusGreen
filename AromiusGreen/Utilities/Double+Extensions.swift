//
//  Double+Extensions.swift
//  AromiusGreen
//
//  Created by VictorZima on 12/09/2024.
//

import Foundation

extension Double {
    func formattedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self))?.trimmingCharacters(in: .whitespaces) ?? String(format: "%.2f", self)
    }
}
