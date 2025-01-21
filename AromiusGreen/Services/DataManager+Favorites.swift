//
//  DataManager+Favorites.swift
//  AromiusGreen
//
//  Created by VictorZima on 14/01/2025.
//

import Firebase
import FirebaseFirestoreSwift
import SwiftUI

extension DataManager {
    
    func addToFavorites(product: Product) {
        guard let productId = product.id else {
            debugLog("Error: product has no id")
            return
        }
        
        let db = Firestore.firestore()
        let favoritesRef = db.collection("users").document(currentUserId).collection("favorites")
        
        guard let thumbnailImage = product.thumbnailImage else {
            return
        }
        let favoriteProduct = FavoriteProduct(
            productId: productId,
            title: product.title,
            manufacturer: product.manufacturer,
            productLine: product.productLine,
            thumbnailImage: thumbnailImage
        )
        
        favoritesRef.document(productId).getDocument { document, error in
            if let document = document, document.exists {
                debugLog("Product already exists")
            } else {
                do {
                    try favoritesRef.document(productId).setData(from: favoriteProduct) { error in
                        if let error = error {
                            debugLog("Error adding product to favorites: \(error.localizedDescription)")
                        } else {
                            debugLog("Product added to favorites")
                        }
                    }
                } catch {
                    debugLog("Error decoding favorite: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func removeFromFavorites(productId: String) {
        let db = Firestore.firestore()
        let favoritesRef = db.collection("users").document(currentUserId).collection("favorites")
        
        favoritesRef.document(productId).delete { error in
            if let error = error {
                debugLog("Error removing favorite: \(error.localizedDescription)")
            } else {
                debugLog("Product removed from favorites")
            }
        }
    }
    
    func isFavorite(productId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let favoritesRef = db.collection("users").document(currentUserId).collection("favorites")
        
        favoritesRef.document(productId).getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func fetchFavorites(completion: @escaping ([FavoriteProduct]) -> Void) {
        let db = Firestore.firestore()
        let favoritesRef = db.collection("users").document(currentUserId).collection("favorites")
        
        favoritesRef.getDocuments { (snapshot, error) in
            if let error = error {
                debugLog("Error fetching favorites: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let snapshot = snapshot {
                let favoriteProducts = snapshot.documents.compactMap { document -> FavoriteProduct? in
                    do {
                        let favoriteProduct = try document.data(as: FavoriteProduct.self)
                        return favoriteProduct
                    } catch {
                        debugLog("Error decoding favorite product: \(error.localizedDescription)")
                        return nil
                    }
                }
                completion(favoriteProducts)
            } else {
                completion([])
            }
        }
    }
}
