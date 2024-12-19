//
//  Category.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import FirebaseFirestoreSwift

struct Category: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var icon: String
    var sortIndex: Int
}
