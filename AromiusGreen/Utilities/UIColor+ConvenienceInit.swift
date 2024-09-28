//
//  UIColor+ConvenienceInit.swift
//  AromiusGreen
//
//  Created by VictorZima on 24/09/2024.
//

import UIKit

extension UIColor {
    public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alpha
        )
    }
}
