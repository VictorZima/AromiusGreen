//
//  AppUser.swift
//  AromiusGreen
//
//  Created by VictorZima on 26/08/2024.
//

import FirebaseFirestoreSwift

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    var firstName: String
    var secondName: String
    var country: String
    var city: String
    var email: String
    var photo: String?
    var isAdmin: Bool = false
    
    var fullName: String {
        return "\(firstName) \(secondName)"
    }

    enum CodingKeys: String, CodingKey {
        case firstName
        case secondName
        case country
        case city
        case email
        case photo
        case isAdmin
    }
}
