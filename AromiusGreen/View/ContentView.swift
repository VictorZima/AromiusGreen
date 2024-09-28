//
//  ContentView.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        TabView {
            Home()
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                    }
                }
            FavoritesView()
                .tabItem {
                    VStack {
                        Image(systemName: "suit.heart.fill")
                    }
                }
            InfoView()
                .tabItem {
                    VStack {
                        Image(systemName: "map")
                    }
                }
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                    }
                }
            CartView()
                .tabItem {
                    VStack {
                        Image(systemName: "cart")
                    }
                }
                .badge(cartManager.cartItems.count > 0 ? "\(cartManager.cartItems.count)" : nil)
        }
        .tint(.darkBlueItem)
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
        .environmentObject(AuthManager())
        .environmentObject(CartManager())
}
