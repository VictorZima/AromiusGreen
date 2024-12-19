//
//  FavoritesViewModel.swift
//  AromiusGreen
//
//  Created by VictorZima on 08/11/2024.
//

import SwiftUI
import FirebaseStorage

class FavoritesViewModel: ObservableObject {
    @Published var favoriteProducts: [FavoriteProduct] = []
    @Published var isShowingAuthView = false
    
    var dataManager: DataManager?
    var authManager: AuthManager?
    
    init() {}

    func fetchFavorites() {
        guard let authManager = authManager, authManager.isUserAuthenticated else {
            self.favoriteProducts = []
            return
        }
        dataManager?.fetchFavorites { [weak self] products in
            DispatchQueue.main.async {
                self?.favoriteProducts = products
            }
        }
    }
}
