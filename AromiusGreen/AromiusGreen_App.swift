//
//  AromiusGreen_App.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct AromiusGreen_App: App {
    @StateObject var dataManager = DataManager()
    @StateObject var authManager = AuthManager()
    @StateObject var cartManager = CartManager()

    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(authManager)
                .environmentObject(cartManager)
        }
    }
}

