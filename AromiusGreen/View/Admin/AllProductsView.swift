//
//  AllProductsView.swift
//  AromiusGreen
//
//  Created by VictorZima on 10/09/2024.
//

import SwiftUI

struct AllProductsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        if authManager.currentUser?.isAdmin == true {
            
            List {
                ForEach(dataManager.products) { item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                            .bold()
                        Text(item.manufactureName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
                            Text("\(item.price.formattedPrice()) ₽")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            Text("\(item.purchasePrice.formattedPrice()) ₽")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("All Products")                
            
        } else {
            Text("Access Denied")
                .font(.title)
                .foregroundColor(.red)
        }
    }
}

#Preview {
    AllProductsView()
        .environmentObject(AuthManager())
        .environmentObject(DataManager())
}
