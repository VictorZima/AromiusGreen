//
//  AdminHomeView.swift
//  AromiusGreen
//
//  Created by VictorZima on 09/09/2024.
//

import SwiftUI

struct AdminHomeView: View {
    private let adminSections: [AdminSection] = [
        AdminSection(title: "Orders", destination: AnyView(AdminOrdersView())),
        AdminSection(title: "Products", destination: AnyView(AllProductsView(dataManager: DataManager()))),
        AdminSection(title: "Manufacturers", destination: AnyView(ManufacturersView()))
    ]
    
    var body: some View {
        AdminView {
            VStack(spacing: 20) {
                ForEach(adminSections) { section in
                    CustomNavigationButton(title: section.title, widthSize: .large, destination: section.destination)
                }
                Spacer()
            }
            .padding(40)
            .navigationTitle("Admin Dashboard")
        }
    }
}

#Preview {
    AdminHomeView()
}
