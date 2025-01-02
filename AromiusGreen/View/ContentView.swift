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
    
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Home()
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                    }
                }
                .tag(Tab.home)

            FavoritesView()
                .tabItem {
                    VStack {
                        Image(systemName: "suit.heart.fill")
                    }
                }
                .tag(Tab.favorites)
                .environmentObject(favoritesViewModel)
            InfoView()
                .tabItem {
                    VStack {
                        Image(systemName: "map")
                    }
                }
                .tag(Tab.info)
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                    }
                }
                .tag(Tab.profile)
            CartView()
                .tabItem {
                    VStack {
                        Image(systemName: "cart")
                    }
                }
                .tag(Tab.cart)
                .badge(authManager.isUserAuthenticated && cartManager.cartItems.count > 0 ? "\(cartManager.cartItems.count)" : nil)
        }
        .tint(.darkBlueItem)
        .onAppear {
            favoritesViewModel.dataManager = dataManager
            favoritesViewModel.authManager = authManager
            favoritesViewModel.fetchFavorites()
        }
    }
}

enum Tab: String {
    case home = "Home"
    case favorites = "Favorites"
    case info = "Info"
    case profile = "Profile"
    case cart = "Cart"
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
        .environmentObject(AuthManager())
        .environmentObject(CartManager())
}
