//
//  AdminHomeView.swift
//  AromiusGreen
//
//  Created by VictorZima on 09/09/2024.
//

import SwiftUI

struct AdminHomeView: View {
    private let adminSections: [AdminSection] = [
        AdminSection(title: "admin_orders_buttons", destination: AnyView(AdminOrdersView())),
        AdminSection(title: "admin_roducts_buttons", destination: AnyView(AllProductsView(dataManager: DataManager()))),
        AdminSection(title: "admin_manufacturers_buttons", destination: AnyView(ManufacturersView()))
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
            .navigationTitle("admin_dasboard_title")
        }
    }
}

#Preview {
    AdminHomeView()
}
