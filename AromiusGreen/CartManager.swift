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
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован, корзина не будет сохранена.")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
            // Увеличиваем количество
            cartItems[index].quantity += 1
            
            let updatedItem = cartItems[index]
            
            // Обновляем количество в Firestore
            cartRef.document(updatedItem.id.uuidString).updateData([
                "quantity": updatedItem.quantity
            ]) { error in
                if let error = error {
                    print("Ошибка при обновлении количества товара: \(error.localizedDescription)")
                } else {
                    print("Количество товара успешно увеличено")
                }
            }
        }
    }

    func decreaseQuantity(of productId: UUID) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован, корзина не будет сохранена.")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
                
                let updatedItem = cartItems[index]
                cartRef.document(updatedItem.id.uuidString).updateData([
                    "quantity": updatedItem.quantity
                ]) { error in
                    if let error = error {
                        print("Ошибка при обновлении количества товара: \(error.localizedDescription)")
                    } else {
                        print("Количество товара успешно увеличено")
                    }
                }
            } else {
                // Если количество равно 1, удаляем товар
                let documentId = cartItems[index].id.uuidString
                cartRef.document(documentId).delete { [weak self] error in
                    if let error = error {
                        print("Ошибка при удалении товара: \(error.localizedDescription)")
                    } else {
                        print("Товар успешно удален из Firestore")
                        self?.cartItems.remove(at: index)
                    }
                }
            }
        } else {
            print("Товар с таким ID не найден в корзине")
        }
    }

    func removeFromCart(productId: UUID) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован, корзина не будет сохранена.")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
            let itemId = cartItems[index].id.uuidString
            
            // Сначала пытаемся удалить из базы данных
            cartRef.document(itemId).delete { [weak self] error in
                if let error = error {
                    print("Ошибка при удалении товара из корзины: \(error.localizedDescription)")
                } else {
                    print("Товар успешно удален из корзины в базе данных")
                    // Только после успешного удаления из базы удаляем из локального массива
                    self?.cartItems.remove(at: index)
                }
            }
        } else {
            print("Товар с таким ID не найден в корзине")
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
                        id: UUID(uuidString: document.documentID) ?? UUID(),
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
    
    func clearCart() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован, корзина не может быть очищена.")
            return
        }

        let cartRef = db.collection("users").document(userId).collection("carts")
        
        // Удаление всех товаров из Firestore
        cartRef.getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка при очистке корзины: \(error.localizedDescription)")
                return
            }

            snapshot?.documents.forEach { document in
                cartRef.document(document.documentID).delete { error in
                    if let error = error {
                        print("Ошибка при удалении товара: \(error.localizedDescription)")
                    } else {
                        print("Товар успешно удален")
                    }
                }
            }
        }

        // Очистка локальных данных
        cartItems.removeAll()
        print("Корзина успешно очищена")
    }
}
