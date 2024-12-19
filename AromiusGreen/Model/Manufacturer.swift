//
//  Manufacturer.swift
//  AromiusGreen
//
//  Created by VictorZima on 11/09/2024.
//

import FirebaseFirestoreSwift

struct Manufacturer: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var manufacturerDescription: String?
    var logo: String?
//    var productLines: [ProductLine]?
    var isShow: Bool
}

