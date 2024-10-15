//
//  Double+Extensions.swift
//  AromiusGreen
//
//  Created by VictorZima on 12/09/2024.
//

import Foundation

extension Double {
    func formattedPrice() -> String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(self))"
        } else {
            return String(format: "%.2f", self)
        }
    }
}
