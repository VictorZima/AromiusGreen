//
//  AppUser.swift
//  AromiusGreen
//
//  Created by VictorZima on 26/08/2024.
//

import FirebaseFirestoreSwift

struct AppUser: Identifiable, Codable {
    var id: String
    var firstName: String?
    var secondName: String?
    var country: String?
    var city: String?
    var email: String
    var photo: String?
    var isAdmin: Bool = false
    
    var fullName: String {
        let firstName = self.firstName ?? ""
        let secondName = self.secondName ?? ""
        if firstName.isEmpty {
                return secondName
            } else if secondName.isEmpty {
                return firstName
            } else {
                return "\(firstName) \(secondName)"
            }
    }
}
