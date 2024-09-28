//
//  AppUser.swift
//  AromiusGreen
//
//  Created by VictorZima on 26/08/2024.
//

import Foundation

struct AppUser: Identifiable {
    var id: UUID = UUID()
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
}
