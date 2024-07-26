//
//  Product.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI

struct Product: Identifiable {
    var id: UUID = .init()
    var name: String
    var descr: String
    var value: String
    var categories: [String]
    var manufactureId: Int
    var manufactureName: String
    var productLineId: Int
    var productLineName: String
    var image: String
    var thumbnailImage: String
    var price: Int
}
