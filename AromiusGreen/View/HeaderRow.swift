//
//  HeaderRow.swift
//  AromiusGreen
//
//  Created by VictorZima on 24/08/2024.
//

import SwiftUI

struct HeaderRow: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isShowingSettings = false
    @State private var isShowingAuth = false
    
    var body: some View {
        HStack {
            Text("Dead Sea Cosmetics\nfrom")
                .font(.system(size: 18))
            + Text(" AROMIUS")
                .foregroundColor(.darkBlueItem)
                .font(.system(size: 20, weight: .bold))
            + Text(" shop")
                .font(.system(size: 18))
            
            Spacer()
            personButton
        }
        .padding(30)
    }
    
    var personButton: some View {
        Button(action: {
            if authManager.isUserAuthenticated {
                isShowingSettings = true
            } else {
                isShowingAuth = true
            }
        }) {
            Image(systemName: "person.and.background.dotted")
                .foregroundColor(.green)
                .imageScale(.large)
                .frame(width: 60, height: 50)
                .overlay(RoundedRectangle(cornerRadius: 17).stroke().opacity(0.2).foregroundColor(.green))
        }
        .sheet(isPresented: $isShowingSettings) {
            ProfileView()
        }
        .sheet(isPresented: $isShowingAuth) {
            AuthView()
                .environmentObject(authManager)
        }
    }
    
}

#Preview {
    HeaderRow()
}
