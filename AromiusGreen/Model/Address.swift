//
//  Address.swift
//  AromiusGreen
//
//  Created by VictorZima on 10/10/2024.
//

import Foundation
import FirebaseFirestoreSwift

struct Address: Identifiable, Codable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var phone: String
    var country: String
    var city: String
    var street: String
    var zipCode: String?
    var isPrimary: Bool = false
}
