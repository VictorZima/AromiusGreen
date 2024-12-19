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
import FirebaseFirestoreSwift

class DataManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    @Published var manufacturers: [Manufacturer] = []
    @Published var productLines: [ProductLine] = []
    @Published var deliveryMethods: [DeliveryMethod] = []
    @Published var isDataLoaded = false
    
    private var db = Firestore.firestore()
    private var productsListener: ListenerRegistration?
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    init() {
        fetchCategories()
        fetchManufacturersAdmin()
        addProductsListener()
    }
    
    deinit {
        productsListener?.remove()
    }
  
    func addProductsListener() {
        let collectionRef = db.collection("items")
        
        productsListener = collectionRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                if let error = error {
                    print("Ошибка при получении продуктов: \(error.localizedDescription)")
                }
                return
            }

            self.products = snapshot.documents.compactMap { document in
                do {
                    var product = try document.data(as: Product.self)
                    product.id = document.documentID
                    return product
                } catch {
                    print("Ошибка при декодировании продукта: \(error.localizedDescription)")
                    return nil
                }
            }
            self.isDataLoaded = true // Обновляем флаг после загрузки данных
        }
    }
    
//    func addProductsListener() {
//        let collectionRef = db.collection("items")
//        
//        productsListener = collectionRef.addSnapshotListener { snapshot, error in
//            guard let snapshot = snapshot else {
//                if let error = error {
//                    print("Ошибка при получении продуктов: \(error.localizedDescription)")
//                }
//                return
//            }
//
//            self.products = snapshot.documents.compactMap { document in
//                do {
//                    var product = try document.data(as: Product.self)
//                    product.id = document.documentID
//                    return product
//                } catch {
//                    print("Ошибка при декодировании продукта: \(error.localizedDescription)")
//                    return nil
//                }
//            }
//        }
//    }
    
    func fetchProductById(productId: String, completion: @escaping (Product?) -> Void) {
        let docRef = db.collection("items").document(productId)

        docRef.getDocument { document, error in
            if let error = error {
                print("Ошибка при получении продукта: \(error.localizedDescription)")
                completion(nil)
            } else if let document = document, document.exists {
                do {
                    let product = try document.data(as: Product.self)
                    completion(product)
                } catch {
                    print("Ошибка при декодировании продукта: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                print("Продукт не найден")
                completion(nil)
            }
        }
    }
  
    func addProduct(_ product: Product, completion: @escaping (Result<Product, Error>) -> Void) {
        let docRef = db.collection("products").document()
        var newProduct = product
        newProduct.id = docRef.documentID
        do {
            try docRef.setData(from: newProduct) { [weak self] error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        self?.products.append(newProduct)
                    }
                    completion(.success(newProduct))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
     
    func fetchManufacturers(completion: @escaping (Result<[Manufacturer], Error>) -> Void) {
        db.collection("manufacturers").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Ошибка при получении производителей: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            let manufacturers = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Manufacturer.self)
            } ?? []
            DispatchQueue.main.async {
                self?.manufacturers = manufacturers
            }
            completion(.success(manufacturers))
        }
    }
    
    func fetchManufacturersAdmin() {
        let manufacturersRef = db.collection("manufacturers")
        manufacturersRef.getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Ошибка при получении производителей: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("Нет данных производителей")
                return
            }
            
            DispatchQueue.main.async {
                self?.manufacturers = documents.compactMap { document in
                    do {
                        var manufacturer = try document.data(as: Manufacturer.self)
                        manufacturer.id = document.documentID
                        return manufacturer
                    } catch {
                        print("Ошибка при декодировании производителя: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
        }
    }
    
    func addManufacturer(_ manufacturer: Manufacturer, completion: @escaping (Result<Manufacturer, Error>) -> Void) {
        let docRef = db.collection("manufacturers").document()
        var newManufacturer = manufacturer
        newManufacturer.id = docRef.documentID
        do {
            try docRef.setData(from: newManufacturer) { [weak self] error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        self?.manufacturers.append(newManufacturer)
                    }
                    completion(.success(newManufacturer))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func fetchProductLines(completion: @escaping (Result<[ProductLine], Error>) -> Void) {
        db.collectionGroup("productLines").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Ошибка при получении продуктовых линеек: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            let productLines = querySnapshot?.documents.compactMap { document in
                try? document.data(as: ProductLine.self)
            } ?? []
            DispatchQueue.main.async {
                self?.productLines = productLines
            }
            completion(.success(productLines))
        }
    }
    
    func addProductLine(_ productLine: ProductLine, to manufacturer: Manufacturer, completion: @escaping (Result<ProductLine, Error>) -> Void) {
        guard let manufacturerID = manufacturer.id else {
            completion(.failure(NSError(domain: "Invalid manufacturer ID", code: 0, userInfo: nil)))
            return
        }
        
        let docRef = db.collection("manufacturers").document(manufacturerID).collection("productLines").document()
        var newProductLine = productLine
        newProductLine.id = docRef.documentID
        newProductLine.manufacturerId = manufacturerID
        do {
            try docRef.setData(from: newProductLine) { [weak self] error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        self?.productLines.append(newProductLine)
                    }
                    completion(.success(newProductLine))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func fetchCategories() {
        categories.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("categories").order(by: "sortIndex")
        ref.getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка при получении категорий: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                self.categories = snapshot.documents.compactMap { document in
                    do {
                        var category = try document.data(as: Category.self)
                        if category.id == nil {
                            category.id = document.documentID
                        }
                        return category
                    } catch {
                        print("Ошибка при декодировании категории: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
        }
    }
    
    func addToFavorites(product: Product) {
        guard let productId = product.id else {
            print("Ошибка: у продукта нет идентификатора")
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
                print("Продукт уже находится в избранном")
            } else {
                do {
                    try favoritesRef.document(productId).setData(from: favoriteProduct) { error in
                        if let error = error {
                            print("Ошибка при добавлении в избранное: \(error.localizedDescription)")
                        } else {
                            print("Продукт успешно добавлен в избранное")
                        }
                    }
                } catch {
                    print("Ошибка при кодировании избранного продукта: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func removeFromFavorites(productId: String) {
        let db = Firestore.firestore()
        let favoritesRef = db.collection("users").document(currentUserId).collection("favorites")

        favoritesRef.document(productId).delete { error in
            if let error = error {
                print("Ошибка при удалении из избранного: \(error.localizedDescription)")
            } else {
                print("Продукт успешно удален из избранного")
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
                print("Ошибка при получении избранного: \(error.localizedDescription)")
                completion([])
                return
            }

            if let snapshot = snapshot {
                let favoriteProducts = snapshot.documents.compactMap { document -> FavoriteProduct? in
                    do {
                        let favoriteProduct = try document.data(as: FavoriteProduct.self)
                        return favoriteProduct
                    } catch {
                        print("Ошибка при декодировании избранного продукта: \(error.localizedDescription)")
                        return nil
                    }
                }
                completion(favoriteProducts)
            } else {
                completion([])
            }
        }
    }
    
    
    func createOrder(cartItems: [CartItem], totalAmount: Double, deliveryMethod: String, deliveryCost: Double, deliveryAddress: Address, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let orderRef = db.collection("orders").document()
        
        let finalTotalAmount = totalAmount + deliveryCost
        
        var order = Order(
            userId: userId,
            items: cartItems,
            totalAmount: finalTotalAmount,
            deliveryMethod: deliveryMethod,
            deliveryCost: deliveryCost,
            deliveryAddress: deliveryAddress
        )
        order.statusHistory.append(OrderStatusHistory(status: order.status))
        
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
    
    
    
    func fetchOrders(for userId: String, completion: @escaping ([Order]) -> Void) {
        let db = Firestore.firestore()
        let ordersRef = db.collection("orders").whereField("userId", isEqualTo: userId)
        
        ordersRef.getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка при получении заказов: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let snapshot = snapshot {
                let fetchedOrders = snapshot.documents.compactMap { document in
                    do {
                        var order = try document.data(as: Order.self)
                        order.id = document.documentID
                        return order
                    } catch {
                        print("Ошибка при декодировании заказа: \(error.localizedDescription)")
                        return nil
                    }
                }
                completion(fetchedOrders)
            } else {
                completion([])
            }
        }
    }
    
    func fetchAllOrdersForAdmin(completion: @escaping ([Order]) -> Void) {
        let db = Firestore.firestore()
        db.collection("orders").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching all orders: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let snapshot = snapshot {
                let orders = snapshot.documents.compactMap { document -> Order? in
                    do {
                        var order = try document.data(as: Order.self)
                        order.id = document.documentID
                        return order
                    } catch {
                        print("Ошибка при декодировании заказа: \(error.localizedDescription)")
                        return nil
                    }
                }
                completion(orders)
            } else {
                completion([])
            }
        }
    }
    
    func updateOrderStatus(orderId: String, newStatus: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let orderRef = db.collection("orders").document(orderId)
        
        orderRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    var order = try document.data(as: Order.self)
                    
                    let newStatusHistory = OrderStatusHistory(status: newStatus) // Добавляем статус с текущим временем
                    order.statusHistory.append(newStatusHistory)
                    
                    order.status = newStatus
                    order.updatedAt = Date() // Обновляем время обновления заказа
                    
                    try orderRef.setData(from: order) { error in
                        if let error = error {
                            print("Ошибка при обновлении заказа: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Статус заказа успешно обновлен")
                            completion(true)
                        }
                    }
                } catch {
                    print("Ошибка при чтении данных заказа: \(error.localizedDescription)")
                    completion(false)
                }
            } else {
                print("Документ заказа не найден")
                completion(false)
            }
        }
    }
    
    func fetchUserAddresses(completion: @escaping ([Address]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("addresses").getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка при получении адресов: \(error.localizedDescription)")
                completion([])
            } else {
                let addresses = snapshot?.documents.compactMap { document -> Address? in
                    var address = try? document.data(as: Address.self)
                    address?.id = document.documentID
                    return address
                } ?? []
                completion(addresses)
            }
        }
    }
    
    func resetPrimaryAddress(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let addressesRef = db.collection("users").document(userId).collection("addresses")
        
        addressesRef.whereField("isPrimary", isEqualTo: true).getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка при получении основного адреса: \(error.localizedDescription)")
                completion(false)
            } else {
                let batch = db.batch()
                snapshot?.documents.forEach { document in
                    batch.updateData(["isPrimary": false], forDocument: document.reference)
                }
                batch.commit { error in
                    if let error = error {
                        print("Ошибка при сбросе основного адреса: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func updateAddress(_ address: Address, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid, let addressId = address.id else {
            print("Ошибка: address.id is nil")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encodeWithoutID(address)
            db.collection("users")
                .document(userId)
                .collection("addresses")
                .document(addressId)
                .setData(data) { error in
                    if let error = error {
                        print("Ошибка при обновлении адреса: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Адрес успешно обновлен")
                        completion(true)
                    }
                }
        } catch {
            print("Ошибка при кодировании адреса: \(error.localizedDescription)")
            completion(false)
        }
    }
    
   
    func addAddress(_ address: Address, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Ошибка: пользователь не авторизован")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("users")
            .document(userId)
            .collection("addresses")
            .document()

        var newAddress = address
        newAddress.id = docRef.documentID

        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encodeWithoutID(newAddress)
            docRef.setData(data) { error in
                if let error = error {
                    print("Ошибка при добавлении адреса: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Адрес успешно добавлен")
                    completion(true)
                }
            }
        } catch {
            print("Ошибка при кодировании адреса: \(error.localizedDescription)")
            completion(false)
        }
    }
   
    func deleteAddress(_ address: Address, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid, let addressId = address.id else {
            print("Ошибка: отсутствует идентификатор пользователя или адреса")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("addresses").document(addressId).delete { error in
            if let error = error {
                print("Ошибка при удалении адреса: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Адрес успешно удален")
                completion(true)
            }
        }
    }
    
    func fetchDeliveryMethods(completion: @escaping ([DeliveryMethod]) -> Void) {
        let db = Firestore.firestore()
        let deliveryMethodsRef = db.collection("deliveryMethods")
        
        deliveryMethodsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка при получении способов доставки: \(error.localizedDescription)")
                completion([])
            } else if let snapshot = snapshot {
                let methods = snapshot.documents.compactMap { document -> DeliveryMethod? in
                    var method = try? document.data(as: DeliveryMethod.self)
                    method?.id = document.documentID
                    return method
                }
                completion(methods)
            } else {
                completion([])
            }
        }
    }
}

extension Firestore.Encoder {
    func encodeWithoutID<T>(_ value: T) throws -> [String: Any] where T: Encodable {
        var dict = try self.encode(value)
        dict.removeValue(forKey: "id")
        return dict
    }
}

extension OrderStatusHistory {
    var dictionary: [String: Any] {
        return [
            "status": status,
            "date": Timestamp(date: date)
        ]
    }
}
