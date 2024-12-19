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
    var manufacturer: ManufacturerSummary?
    var productLine: ProductLineSummary?
    var thumbnailImage: String
}
