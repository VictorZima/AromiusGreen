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
            print("Пользователь не авторизован, корзина не будет сохранена.")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        guard let productId = product.id else {
            print("Ошибка: у продукта нет идентификатора")
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
                        print("Ошибка при обновлении количества товара: \(error.localizedDescription)")
                    } else {
                        print("Количество товара успешно обновлено")
                    }
                }
            } else {
                print("Ошибка: отсутствует идентификатор элемента корзины.")
            }
        } else {
            guard let thumbnailImage = product.thumbnailImage else {
                print("Ошибка: некоторые свойства продукта отсутствуют.")
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
                    print("Ошибка при добавлении товара: \(error.localizedDescription)")
                } else {
                    print("Товар успешно добавлен в корзину")
                    
                    if let documentId = ref?.documentID {
                        var newItemWithID = newItem
                        newItemWithID.id = documentId
                        self.cartItems.append(newItemWithID)
                    } else {
                        print("Ошибка: не удалось получить идентификатор нового документа.")
                    }
                }
            }
        }
    }
    
    func increaseQuantity(of productId: String) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован, корзина не будет сохранена.")
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
                        print("Ошибка при обновлении количества товара: \(error.localizedDescription)")
                    } else {
                        print("Количество товара успешно увеличено")
                    }
                }
            } else {
                print("Ошибка: отсутствует идентификатор элемента корзины.")
            }
        }
    }

    func decreaseQuantity(of productId: String) {
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
                
                if let itemId = updatedItem.id {
                    cartRef.document(itemId).updateData([
                        "quantity": updatedItem.quantity
                    ]) { error in
                        if let error = error {
                            print("Ошибка при обновлении количества товара: \(error.localizedDescription)")
                        } else {
                            print("Количество товара успешно уменьшено")
                        }
                    }
                } else {
                    print("Ошибка: отсутствует идентификатор элемента корзины.")
                }
            } else {
                // Если количество равно 1, удаляем товар
                if let documentId = cartItems[index].id {
                    cartRef.document(documentId).delete { [weak self] error in
                        if let error = error {
                            print("Ошибка при удалении товара: \(error.localizedDescription)")
                        } else {
                            print("Товар успешно удален из Firestore")
                            self?.cartItems.remove(at: index)
                        }
                    }
                } else {
                    print("Ошибка: отсутствует идентификатор элемента корзины.")
                }
            }
        } else {
            print("Товар с таким ID не найден в корзине")
        }
    }

    func removeFromCart(productId: String) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован, корзина не будет сохранена.")
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        if let index = cartItems.firstIndex(where: { $0.productId == productId }) {
            if let itemId = cartItems[index].id {
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
                print("Ошибка: отсутствует идентификатор элемента корзины.")
            }
        } else {
            print("Товар с таким ID не найден в корзине")
        }
    }
    
    func totalPrice() -> Double {
        return cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    func loadCartFromDatabase() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.errorMessage = "Пользователь не авторизован, корзина не может быть загружена."
            }
            return
        }
        
        let cartRef = db.collection("users").document(userId).collection("carts")
        
        cartRef.getDocuments { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Ошибка при загрузке корзины: \(error.localizedDescription)"
                }
                return
            }
            
            guard let snapshot = snapshot else {
                DispatchQueue.main.async {
                    self.errorMessage = "Нет данных в корзине."
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
    
//    func loadCartFromDatabase() {
//        let db = Firestore.firestore()
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("Пользователь не авторизован, корзина не может быть загружена.")
//            return
//        }
//        
//        let cartRef = db.collection("users").document(userId).collection("carts")
//        
//        cartRef.getDocuments { snapshot, error in
//            if let error = error {
//                print("Ошибка при загрузке корзины: \(error.localizedDescription)")
//                return
//            }
//            
//            if let snapshot = snapshot {
//                self.cartItems = snapshot.documents.compactMap { document -> CartItem? in
//                    let data = document.data()
//                    
//                    guard let productId = data["productId"] as? String,
//                          let title = data["title"] as? String,
//                          let price = data["price"] as? Double,
//                          let quantity = data["quantity"] as? Int,
//                          let thumbnailImage = data["thumbnailImage"] as? String else { return nil }
//                    
//                    return CartItem(
//                        id: document.documentID,
//                        productId: productId,
//                        title: title,
//                        price: price,
//                        quantity: quantity,
//                        thumbnailImage: thumbnailImage
//                    )
//                }
//            }
//        }
//    }
    
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
