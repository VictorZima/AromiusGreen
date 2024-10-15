//
//  Manufacture.swift
//  AromiusGreen
//
//  Created by VictorZima on 11/09/2024.
//

import FirebaseFirestoreSwift

struct Manufacture: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var logo: String

    enum CodingKeys: String, CodingKey {
        case title
        case logo
    }
}

