//
//  ProductLine.swift
//  AromiusGreen
//
//  Created by VictorZima on 11/09/2024.
//

import FirebaseFirestoreSwift

struct ProductLine: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var lineDescription: String?
    var logo: String?
    var isShow: Bool
    var manufacturerId: String
}
