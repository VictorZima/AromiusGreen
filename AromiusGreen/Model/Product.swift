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
    var barcode: String?
    var descr: String
    var value: String?
    var categoryIds: [String]
    var manufactureId: String
    var manufactureName: String
    var productLineId: String
    var productLineName: String
    var image: String
    var thumbnailImage: String
    var price: Double
    var purchasePrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case title
        case barcode
        case descr = "description"
        case value
        case categoryIds
        case manufactureId
        case manufactureName
        case productLineId
        case productLineName
        case image
        case thumbnailImage
        case price
        case purchasePrice
    }
}
