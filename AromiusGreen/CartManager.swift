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
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован, корзина не будет сохранена.")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        if let index = cartItems.firstIndex(where: { $0.productId == product.id }) {
            cartItems[index].quantity += quantity
            
            let updatedItem = cartItems[index]
            cartRef.document(updatedItem.id.uuidString).updateData([
                "quantity": updatedItem.quantity
            ]) { error in
                if let error = error {
                    print("Ошибка при обновлении количества товара: \(error.localizedDescription)")
                } else {
                    print("Количество товара успешно обновлено")
                }
            }
        } else {
            let newItem = CartItem(
                productId: product.id,
                name: product.name,
                price: product.price,
                quantity: quantity,
                thumbnailImage: product.thumbnailImage
            )
            cartItems.append(newItem)
            cartRef.document(newItem.id.uuidString).setData([
                "productId": newItem.productId.uuidString,
                "name": newItem.name,
                "price": newItem.price,
                "quantity": newItem.quantity,
                "thumbnailImage": newItem.thumbnailImage
            ]) { error in
                if let error = error {
                    print("Ошибка при добавлении товара: \(error.localizedDescription)")
                } else {
                    print("Товар успешно добавлен в корзину")
                }
            }
        }
    }
    
     func increaseQuantity(of productId: UUID) {
         if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
             cartItems[index].quantity += 1
//             saveCartToDatabase()
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
//             saveCartToDatabase()
         }
     }

     func removeFromCart(productId: UUID) {
         if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
             cartItems.remove(at: index)
//             saveCartToDatabase()
         }
     }
    
    func totalPrice() -> Double {
        return cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

//    private func saveCartToDatabase() {
//        let db = Firestore.firestore()
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("Пользователь не авторизован, корзина не будет сохранена.")
//            return
//        }
//        
//        let cartData = cartItems.map { item in
//            return [
//                "productId": item.productId.uuidString,
//                "name": item.name,
//                "price": item.price,
//                "quantity": item.quantity,
//                "thumbnailImage": item.thumbnailImage
//            ] as [String: Any]
//        }
//        
//        db.collection("carts").document(userId).setData(["items": cartData]) { error in
//            if let error = error {
//                print("Ошибка при сохранении корзины: \(error.localizedDescription)")
//            } else {
//                print("Корзина успешно сохранена")
//            }
//        }
//    }

    func loadCartFromDatabase() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован, корзина не может быть загружена.")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        cartRef.getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка при загрузке корзины: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot {
                self.cartItems = snapshot.documents.compactMap { document in
                    guard let productIdString = document["productId"] as? String,
                          let productId = UUID(uuidString: productIdString),
                          let name = document["name"] as? String,
                          let price = document["price"] as? Double,
                          let quantity = document["quantity"] as? Int,
                          let thumbnailImage = document["thumbnailImage"] as? String else { return nil }
                    
                    return CartItem(
                        productId: productId,
                        name: name,
                        price: price,
                        quantity: quantity,
                        thumbnailImage: thumbnailImage
                    )
                }
            }
        }
    }
}
