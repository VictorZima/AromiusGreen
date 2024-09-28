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
    
    init() {
        loadCartFromDatabase()
    }

    func addToCart(product: Product, quantity: Int = 1) {
//        guard authManager.isUserAuthenticated else {
//            print("User needs to sign in or register to add items to the cart.")
//            return
//        }
        
        if let index = cartItems.firstIndex(where: { $0.productId == product.id }) {
            cartItems[index].quantity += quantity
        } else {
            let newItem = CartItem(
                productId: product.id,
                name: product.name,
                price: product.price,
                quantity: quantity,
                thumbnailImage: product.thumbnailImage
            )
            cartItems.append(newItem)
        }
        saveCartToDatabase()
    }
    
     func increaseQuantity(of productId: UUID) {
         if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
             cartItems[index].quantity += 1
             saveCartToDatabase()
         }
     }

     func decreaseQuantity(of productId: UUID) {
         if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
             if cartItems[index].quantity > 1 {
                 cartItems[index].quantity -= 1
             } else {
                 // Если количество товара становится 0, удаляем его из корзины
                 cartItems.remove(at: index)
             }
             saveCartToDatabase()
         }
     }

     func removeFromCart(productId: UUID) {
         if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
             cartItems.remove(at: index)
             saveCartToDatabase()
         }
     }
    
    func totalPrice() -> Double {
        return cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    private func saveCartToDatabase() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован, корзина не будет сохранена.")
            return
        }
        
        let cartData = cartItems.map { item in
            return [
                "productId": item.productId.uuidString,
                "name": item.name,
                "price": item.price,
                "quantity": item.quantity,
                "thumbnailImage": item.thumbnailImage
            ] as [String: Any]
        }
        
        db.collection("carts").document(userId).setData(["items": cartData]) { error in
            if let error = error {
                print("Ошибка при сохранении корзины: \(error.localizedDescription)")
            } else {
                print("Корзина успешно сохранена")
            }
        }
    }

    func loadCartFromDatabase() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован, корзина не может быть загружена.")
            return
        }

        db.collection("carts").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                if let cartData = document.data()?["items"] as? [[String: Any]] {
                    self.cartItems = cartData.compactMap { data in
                        guard let productIdString = data["productId"] as? String,
                              let productId = UUID(uuidString: productIdString),
                              let name = data["name"] as? String,
                              let price = data["price"] as? Double,
                              let quantity = data["quantity"] as? Int,
                              let thumbnailImage = data["thumbnailImage"] as? String else { return nil }
                        
                        return CartItem(
                            productId: productId,
                            name: name,
                            price: price,
                            quantity: quantity,
                            thumbnailImage: thumbnailImage
                        )
                    }
                }
            } else {
                print("Ошибка при загрузке корзины: \(error?.localizedDescription ?? "Неизвестная ошибка")")
            }
        }
    }
}
