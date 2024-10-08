//
//  AdminView.swift
//  AromiusGreen
//
//  Created by VictorZima on 09/09/2024.
//

import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        if authManager.currentUser?.isAdmin == true {
            VStack(spacing: 20) {
                NavigationLink(destination: AdminOrdersView()) {
                    Text("Orders")
                        .foregroundColor(Color.darkBlueItem)
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(6)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.darkBlueItem, lineWidth: 1)
                        )
                }
                
                NavigationLink(destination: AllProductsView()) {
                    Text("All products")
                        .foregroundColor(Color.darkBlueItem)
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(6)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.darkBlueItem, lineWidth: 1)
                        )
                }
                
                NavigationLink(destination: AddProductView()) {
                    Text("Add new product")
                        .foregroundColor(Color.darkBlueItem)
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(6)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.darkBlueItem, lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .padding(40)
            .navigationTitle("Admin Dashboard")
            
        } else {
            Text("Access Denied")
                .font(.title)
                .foregroundColor(.red)
        }
    }
}

#Preview {
    AdminView()
}
