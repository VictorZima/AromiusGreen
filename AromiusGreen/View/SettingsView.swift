//
//  SettingsView.swift
//  AromiusGreen
//
//  Created by VictorZima on 10/10/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(alignment: .center) {
            if let _ = authManager.currentUser {
                List {
                    NavigationLink {
                        ShippingInfoView()
                    } label: {
                        Text("settings_shipping_information")
                    }
                }
                .listStyle(.grouped)
                .background(Color.white)
            }
        }
        .background(Color.white)

    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}
