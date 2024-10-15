//
//  ProductLine.swift
//  AromiusGreen
//
//  Created by VictorZima on 11/09/2024.
//

import FirebaseFirestoreSwift

struct ProductLine: Identifiable, Codable {
    @DocumentID var id: String?
    var manufactureId: String
    var title: String
    var logo: String
    var isShow: Bool

    enum CodingKeys: String, CodingKey {
        case manufactureId
        case title
        case logo
        case isShow
    }
}
