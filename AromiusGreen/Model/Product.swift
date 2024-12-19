//
//  Product.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import FirebaseFirestoreSwift

struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var barcode: String
    var productDescription: String?
    var value: String?
    var categoryIds: [String] = []
    var manufacturer: ManufacturerSummary?
    var productLine: ProductLineSummary?
    var image: String?
    var thumbnailImage: String?
    var price: Double = 0.0
    var purchasePrice: Double?
}

struct ManufacturerSummary: Codable {
    var id: String?
    var title: String
    var logo: String?
}

struct ProductLineSummary: Codable {
    var id: String?
    var title: String
    var logo: String?
}
