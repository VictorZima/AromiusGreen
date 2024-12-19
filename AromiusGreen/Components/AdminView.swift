//
//  AdminView.swift
//  AromiusGreen
//
//  Created by VictorZima on 25/10/2024.
//

import SwiftUI

struct AdminView<Content: View>: View {
    @EnvironmentObject var authManager: AuthManager
    let content: () -> Content

    var body: some View {
        Group {
            if authManager.currentUser?.isAdmin == true {
                content()
            } else {
                VStack {
                    Image(systemName: "lock.shield")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.red)
                        .padding()

                    Text("Access Denied")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()

                    Text("You do not have administrator rights to access this section.")
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
            }
        }
    }
}
