//
//  AddressRow.swift
//  AromiusGreen
//
//  Created by VictorZima on 10/10/2024.
//

import SwiftUI

struct AddressRow: View {
    var address: Address

    var body: some View {
        VStack(alignment: .leading) {
            Text("Получатель: \(address.firstName) \(address.lastName)")
                .font(.headline)
            Text("\(address.country), \(address.city)")
            Text(address.street)
                .font(.subheadline)
                .foregroundColor(.gray)
            if let zip = address.zipCode, !zip.isEmpty {
                Text("Zip Code: \(zip)")
                    .font(.subheadline)
            }
            Text("Phone: \(address.phone)")
                .font(.subheadline)
            if address.isPrimary {
                Text("Primary Address")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
}