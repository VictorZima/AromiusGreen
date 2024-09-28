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
                NavigationLink(destination: AllProductsView()) {
                    Text("All products")
                        .foregroundStyle(Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: AddProductView()) {
                    Text("Add new product")
                        .foregroundStyle(Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
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
