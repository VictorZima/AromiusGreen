//
//  DataManager.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseAuth

class DataManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    @Published var productLines: [ProductLine] = []
    @Published var manufacturies: [Manufacture] = []
    private var productsListener: ListenerRegistration?
    
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    init() {
        fetchCategories()
        fetchManufacturies()
        fetchProductLines()
        addProductsListener()
        
    }
    
    deinit {
        productsListener?.remove()
    }
    
    func fetchManufacturies() {
        manufacturies.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("manufacturies").order(by: "id")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let id = data["id"] as? Int ?? 0
                    let name = data["name"] as? String ?? ""
                    let logo = data["logo"] as? String ?? ""
                    
                    let manufacture = Manufacture(id: id, name: name, logo: logo)
                    self.manufacturies.append(manufacture)
                }
            }
        }
    }
    
    func fetchProductLines() {
        productLines.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("productLines").order(by: "id")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let id = data["id"] as? Int ?? 0
                    let name = data["name"] as? String ?? ""
                    let logo = data["logo"] as? String ?? ""
                    let isShow = data["isShow"] as? Bool ?? false
                    
                    let productLine = ProductLine(id: id, name: name, logo: logo, isShow: isShow)
                    self.productLines.append(productLine)
                }
            }
        }
    }
    
    func addProductsListener() {
        let db = Firestore.firestore()
        let collectionRef = db.collection("items")
        productsListener = collectionRef.addSnapshotListener { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                self.products.removeAll()
                for document in snapshot.documents {
                    let data = document.data()
                    let idString = data["id"] as? String ?? UUID().uuidString
                    let id = UUID(uuidString: idString) ?? UUID()
                    let title = data["title"] as? String ?? ""
                    let barcode = data["barcode"] as? String ?? ""
                    let descr = data["description"] as? String ?? ""
                    let value = data["value"] as? String ?? ""
                    let image = data["image"] as? String ?? ""
                    let thumbnailImage = data["thumbnailImage"] as? String ?? ""
                    let price = data["price"] as? Double ?? 0.0
                    let purchasePrice = data["purchasePrice"] as? Double ?? 0.0
                    let categoryIds = data["categoryIds"] as? [String] ?? []
                    let manufactureId = data["manufactureId"] as? Int ?? 0
                    let manufactureName = data["manufactureName"] as? String ?? ""
                    let productLineId = data["productLineId"] as? Int ?? 0
                    let productLineName = data["productLineName"] as? String ?? ""
                    let product = Product(id: id, name: title, barcode: barcode, descr: descr, value: value, categoryIds: categoryIds, manufactureId: manufactureId, manufactureName: manufactureName, productLineId: productLineId, productLineName: productLineName,image: image, thumbnailImage: thumbnailImage, price: price, purchasePrice: purchasePrice)
                    
                    self.products.append(product)
                }
            }
        }
    }
    
    func fetchProductById(productId: UUID, completion: @escaping (Product?) -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("items")
        
        //        print("Fetching product with ID: \(productId.uuidString)")
        
        let query = collectionRef.whereField("id", isEqualTo: productId.uuidString)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching product: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                let document = snapshot.documents.first!
                let data = document.data()
                let product = Product(
                    id: UUID(uuidString: document["id"] as? String ?? "") ?? UUID(),
                    name: data["title"] as? String ?? "",
                    barcode: data["barcode"] as? String ?? "",
                    descr: data["description"] as? String ?? "",
                    value: data["value"] as? String ?? "",
                    categoryIds: data["categoryIds"] as? [String] ?? [],
                    manufactureId: data["manufactureId"] as? Int ?? 0,
                    manufactureName: data["manufactureName"] as? String ?? "",
                    productLineId: data["productLineId"] as? Int ?? 0,
                    productLineName: data["productLineName"] as? String ?? "",
                    image: data["image"] as? String ?? "",
                    thumbnailImage: data["thumbnailImage"] as? String ?? "",
                    price: data["price"] as? Double ?? 0.0,
                    purchasePrice: data["purchasePrice"] as? Double ?? 0.0
                )
                completion(product)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchCategories() {
        categories.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("categories").order(by: "sortIndex")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = data["id"] as? String ?? ""
                    let title = data["title"] as? String ?? ""
                    let icon = data["icon"] as? String ?? ""
                    let sortIndex = data["sortIndex"] as? Int ?? 0
                    
                    let category = Category(id: id, title: title, icon: icon, sortIndex: sortIndex)
                    self.categories.append(category)
                }
            }
        }
    }
    
    func addToFavorites(product: Product) {
        let db = Firestore.firestore()
        let favoritesRef = db.collection("users").document(currentUserId).collection("favorites")
        
        let favoriteProduct = FavoriteProduct(
            id: product.id,
            name: product.name,
            manufactureName: product.manufactureName,
            productLineName: product.productLineName,
            thumbnailImage: product.thumbnailImage
        )
        
        let favoriteData: [String: Any] = [
            "productId": favoriteProduct.id.uuidString,
            "name": favoriteProduct.name,
            "manufactureName": favoriteProduct.manufactureName,
            "productLineName": favoriteProduct.productLineName,
            "thumbnailImage": favoriteProduct.thumbnailImage
        ]
        
        favoritesRef.document(favoriteProduct.id.uuidString).setData(favoriteData, merge: true) { error in
            if let error = error {
                print("Error adding to favorites: \(error.localizedDescription)")
            } else {
                print("Product added to favorites successfully")
            }
        }
    }
    
    func removeFromFavorites(productId: UUID) {  // UUID вместо String
        let db = Firestore.firestore()
        let favoritesRef = db.collection("users").document(currentUserId).collection("favorites")
        
        favoritesRef.document(productId.uuidString).delete { error in  // Преобразуем UUID в строку
            if let error = error {
                print("Error removing from favorites: \(error.localizedDescription)")
            } else {
                print("Product removed from favorites successfully")
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
        
        favoritesRef.getDocuments { (snapshot: QuerySnapshot?, error: Error?) in // Уточняем типы
            if let error = error {
                print("Error fetching favorites: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let snapshot = snapshot {
                let favoriteProducts = snapshot.documents.compactMap { document -> FavoriteProduct? in
                    let data = document.data()
                    guard let idString = data["productId"] as? String,
                          let id = UUID(uuidString: idString),
                          let name = data["name"] as? String,
                          let manufactureName = data["manufactureName"] as? String,
                          let productLineName = data["productLineName"] as? String,
                          let thumbnailImage = data["thumbnailImage"] as? String else {
                        return nil
                    }
                    return FavoriteProduct(id: id, name: name, manufactureName: manufactureName, productLineName: productLineName, thumbnailImage: thumbnailImage)
                }
                completion(favoriteProducts)
            }
        }
    }
    
    func addProduct(item: Product) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        
        ref = db.collection("items").addDocument(data: [
            "id": item.id.uuidString,
            "title": item.name,
            "categoryIds": item.categoryIds,
            "manufactureId": item.manufactureId,
            "manufactureName": item.manufactureName,
            "productLineId": item.productLineId,
            "productLineName": item.productLineName,
            "description": item.descr,
            "price": item.price,
            "value": item.value,
            "image": item.image,
            "thumbnailImage": item.thumbnailImage
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func createOrder(cartItems: [CartItem], totalAmount: Double, deliveryMethod: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let orderRef = db.collection("orders").document() // Создаем новый заказ с уникальным ID
        
        let order = Order(
            userId: userId,
            items: cartItems,
            totalAmount: totalAmount,
            deliveryMethod: deliveryMethod
        )
        
        do {
            try orderRef.setData(from: order) { error in
                if let error = error {
                    print("Ошибка при создании заказа: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Заказ успешно создан")
                    completion(true)
                }
            }
        } catch {
            print("Ошибка при сохранении заказа: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func updateOrderStatus(orderId: String, newStatus: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let orderRef = db.collection("orders").document(orderId)
        
        orderRef.updateData(["status": newStatus]) { error in
            if let error = error {
                print("Ошибка при обновлении статуса заказа: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Статус заказа обновлен на \(newStatus)")
                completion(true)
            }
        }
    }
    
    func fetchOrders(for userId: String, completion: @escaping ([Order]) -> Void) {
        let db = Firestore.firestore()
        let ordersRef = db.collection("orders").whereField("userId", isEqualTo: userId)
        
        ordersRef.getDocuments { (snapshot: QuerySnapshot?, error: Error?) in
            if let error = error {
                print("Ошибка при получении заказов: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let snapshot = snapshot {
                //                print("Документы найдены: \(snapshot.documents.count)") // Отладочная информация
                
                let fetchedOrders = snapshot.documents.compactMap { document -> Order? in
                    let data = document.data()
                    
                    // Отладка данных
                    //                    print("Полученные данные: \(data)")
                    
                    guard let userId = data["userId"] as? String,
                          let itemsData = data["items"] as? [[String: Any]],
                          let totalAmount = data["totalAmount"] as? Double,
                          let status = data["status"] as? String,
                          let createdAt = data["createdAt"] as? Timestamp,
                          let deliveryMethod = data["deliveryMethod"] as? String else {
                        print("Ошибка при преобразовании данных заказа")
                        return nil
                    }
                    
                    // Преобразуем данные items в [CartItem]
                    let items = itemsData.compactMap { itemData -> CartItem? in
                        guard let idString = itemData["id"] as? String,
                              let id = UUID(uuidString: idString),
                              let productIdString = itemData["productId"] as? String,
                              let productId = UUID(uuidString: productIdString),
                              let name = itemData["name"] as? String,
                              let price = itemData["price"] as? Double,
                              let quantity = itemData["quantity"] as? Int,
                              let thumbnailImage = itemData["thumbnailImage"] as? String else {
                            print("Ошибка при преобразовании элемента корзины")
                            return nil
                        }
                        
                        return CartItem(id: id, productId: productId, name: name, price: price, quantity: quantity, thumbnailImage: thumbnailImage)
                    }
                    
                    // Создаем заказ
                    var order = Order(
                        userId: userId,
                        items: items,
                        totalAmount: totalAmount,
                        deliveryMethod: deliveryMethod
                    )
                    
                    // Присваиваем ID документа
                    order.id = document.documentID
                    order.status = status
                    order.createdAt = createdAt.dateValue()
                    
                    return order
                }
                completion(fetchedOrders)
            }
        }
    }
    
    func fetchAllOrders(completion: @escaping ([Order]) -> Void) {
        let db = Firestore.firestore()
        db.collection("orders").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching all orders: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let snapshot = snapshot {
                let orders = snapshot.documents.compactMap { document -> Order? in
                    try? document.data(as: Order.self)
                }
                completion(orders)
            } else {
                completion([])
            }
        }
    }

    func updateOrderStatus(order: Order, newStatus: String) {
            let db = Firestore.firestore()
            let orderRef = db.collection("orders").document(order.id ?? "")
            
            let newHistoryRecord = OrderStatusHistory(status: newStatus)
            var updatedHistory = order.statusHistory
            updatedHistory.append(newHistoryRecord)
            
            // Обновление статуса и записи обновления
            orderRef.updateData([
                "status": newStatus,
                "updatedAt": Date(),
                "statusHistory": updatedHistory.map { try! Firestore.Encoder().encode($0) }
            ]) { error in
                if let error = error {
                    print("Error updating order status: \(error.localizedDescription)")
                } else {
                    print("Order status updated successfully")
                }
            }
        }
}
