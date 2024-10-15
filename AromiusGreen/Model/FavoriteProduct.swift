//
//  FavoriteProduct.swift
//  AromiusGreen
//
//  Created by VictorZima on 22/08/2024.
//

import FirebaseFirestoreSwift

struct FavoriteProduct: Identifiable, Codable {
    @DocumentID var id: String?
    var productId: String
    var title: String
    var manufactureName: String
    var productLineName: String
    var thumbnailImage: String

    enum CodingKeys: String, CodingKey {
        case productId
        case title
        case manufactureName
        case productLineName
        case thumbnailImage
    }
}
