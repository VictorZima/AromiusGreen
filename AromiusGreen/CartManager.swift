//
//  CartManager.swift
//  AromiusGreen
//
//  Created by VictorZima on 20/09/2024.
//

import SwiftUI
import Firebase

class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var errorMessage: String? = nil
    
    init() {
        loadCartFromDatabase()
    }

    func addToCart(product: Product, quantity: Int = 1) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            debugLog("User not logged in. Cart cannot be updated")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        guard let productId = product.id else {
            debugLog("Error getting product ID")
            return
        }
        
        if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
            cartItems[index].quantity += quantity
            
            let updatedItem = cartItems[index]
            
            if let itemId = updatedItem.id {
                cartRef.document(itemId).updateData([
                    "quantity": updatedItem.quantity
                ]) { error in
                    if let error = error {
                        debugLog("Error updating product quantity: \(error.localizedDescription)")
                    } else {
                        debugLog("Product quantity updated")
                    }
                }
            } else {
                debugLog("Error: item ID not found")
            }
        } else {
            guard let thumbnailImage = product.thumbnailImage else {
                debugLog("Error: some product thumbnail image is missing")
                return
            }
            
            let newItem = CartItem(
                productId: productId,
                title: product.title,
                price: product.price,
                quantity: quantity,
                thumbnailImage: thumbnailImage
            )
            
            var ref: DocumentReference? = nil
            ref = cartRef.addDocument(data: [
                "productId": newItem.productId,
                "title": newItem.title,
                "price": newItem.price,
                "quantity": newItem.quantity,
                "thumbnailImage": newItem.thumbnailImage
            ]) { error in
                if let error = error {
                    debugLog("Error adding product to cart: \(error.localizedDescription)")
                } else {
                    debugLog("Product added to cart")
                    
                    if let documentId = ref?.documentID {
                        var newItemWithID = newItem
                        newItemWithID.id = documentId
                        self.cartItems.append(newItemWithID)
                    } else {
                        debugLog("Error getting document ID")
                    }
                }
            }
        }
    }
    
    func increaseQuantity(of productId: String) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            debugLog("User not logged in")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
            cartItems[index].quantity += 1
            
            let updatedItem = cartItems[index]
            
            if let itemId = updatedItem.id {
                cartRef.document(itemId).updateData([
                    "quantity": updatedItem.quantity
                ]) { error in
                    if let error = error {
                        debugLog("Error updating quantity: \(error.localizedDescription)")
                    } else {
                        debugLog("Quantity updated")
                    }
                }
            } else {
                debugLog("Error: cart's id is nil")
            }
        }
    }

    func decreaseQuantity(of productId: String) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            debugLog("User is not logged in. Cart cannot be updated")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
                
                let updatedItem = cartItems[index]
                
                if let itemId = updatedItem.id {
                    cartRef.document(itemId).updateData([
                        "quantity": updatedItem.quantity
                    ]) { error in
                        if let error = error {
                            debugLog("Error updating cart item: \(error.localizedDescription)")
                        } else {
                            debugLog("Quantity updated successfully in Firestore")
                        }
                    }
                } else {
                    debugLog("Error cart's id is nil")
                }
            } else {
                if let documentId = cartItems[index].id {
                    cartRef.document(documentId).delete { [weak self] error in
                        if let error = error {
                            debugLog("Error deleting cart item: \(error.localizedDescription)")
                        } else {
                            debugLog("Product deleted from cart successfully")
                            self?.cartItems.remove(at: index)
                        }
                    }
                } else {
                    debugLog("Error: cart's id is nil")
                }
            }
        } else {
            debugLog("Product not found in cart")
        }
    }

    func removeFromCart(productId: String) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            debugLog("User is not signed in")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
            if let itemId = cartItems[index].id {
                cartRef.document(itemId).delete { [weak self] error in
                    if let error = error {
                        debugLog("Error deleting product: \(error.localizedDescription)")
                    } else {
                        debugLog("Product deleted successfully from the database.")
                        self?.cartItems.remove(at: index)
                    }
                }
            } else {
                debugLog("Error: No item ID found")
            }
        } else {
            debugLog("Product not found in cart")
        }
    }
    
    func totalPrice() -> Double {
        return cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    func loadCartFromDatabase() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.errorMessage = "User isn't logged in, cart can't be loaded."
            }
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        cartRef.getDocuments { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error loading cart: \(error.localizedDescription)"
                }
                return
            }
            
            guard let snapshot = snapshot else {
                DispatchQueue.main.async {
                    self.errorMessage = "Cart haven't data."
                    self.cartItems = []
                }
                return
            }
            
            DispatchQueue.main.async {
                self.cartItems = snapshot.documents.compactMap { document in
                    try? document.data(as: CartItem.self)
                }
            }
        }
    }
    
    func clearCart() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            debugLog("User not signed in")
            return
        }

        let cartRef = db.collection("users").document(userId).collection("carts")
        
        cartRef.getDocuments { snapshot, error in
            if let error = error {
                debugLog("Error: \(error.localizedDescription)")
                return
            }

            snapshot?.documents.forEach { document in
                cartRef.document(document.documentID).delete { error in
                    if let error = error {
                        debugLog("Error deleting product: \(error.localizedDescription)")
                    } else {
                        debugLog("Product deleted.")
                    }
                }
            }
        }
        cartItems.removeAll()
        debugLog("Cart cleared.")
    }
}
