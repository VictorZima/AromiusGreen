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
    @Published var isCategoriesLoaded = false
    @Published var isProductsLoaded = false
    @Published var isDataLoaded = false
    
    var db = Firestore.firestore()
    private var productsListener: ListenerRegistration?
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    init() {
        fetchCategories { _ in }
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
                    print("Error fetching products: \(error.localizedDescription)")
                }
                return
            }
            
            self.products = snapshot.documents.compactMap { document in
                do {
                    var product = try document.data(as: Product.self)
                    product.id = document.documentID
                    return product
                } catch {
                    print("Error decoding product: \(error.localizedDescription)")
                    return nil
                }
            }
            
            DispatchQueue.main.async {
                self.isProductsLoaded = true
                self.checkIfDataLoaded()
            }
        }
    }
    
    func fetchCategories(completion: @escaping ([Category]) -> Void) {
        let ref = db.collection("categories").order(by: "sortIndex")
        ref.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                completion([])
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
                        print("Error decoding category: \(error.localizedDescription)")
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    self.isCategoriesLoaded = true
                    self.checkIfDataLoaded()
                    completion(self.categories)
                }
            } else {
                completion([])
            }
        }
    }
    
    private func checkIfDataLoaded() {
        if isCategoriesLoaded && isProductsLoaded {
            self.isDataLoaded = true
            print("DataManager: All data loaded")
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
    
    func createOrder(cartItems: [CartItem], totalAmount: Double, deliveryMethod: String, deliveryCost: Double, deliveryAddress: Address, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Пользователь не авторизован")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let orderRef = db.collection("orders").document()
        
        let finalTotalAmount = totalAmount + deliveryCost
        
        let order = Order(
            userId: userId,
            items: cartItems,
            totalAmount: finalTotalAmount,
            deliveryMethod: deliveryMethod,
            deliveryCost: deliveryCost,
            deliveryAddress: deliveryAddress
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
    
    func updateOrderStatus(orderId: String, newStatus: OrderStatus, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let orderRef = db.collection("orders").document(orderId)
        
        orderRef.getDocument { document, error in
            if let error = error {
                print("Ошибка при получении заказа: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let document = document, document.exists else {
                print("Документ заказа не найден")
                completion(false)
                return
            }
            
            do {
                var order = try document.data(as: Order.self)
                
                let newStatusHistory = OrderStatusHistory(status: newStatus) // Используем OrderStatus
                order.statusHistory.append(newStatusHistory)
                
                order.status = newStatus // Присваиваем OrderStatus
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
                print("Ошибка при декодировании заказа: \(error.localizedDescription)")
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
    
    func uploadImage(data: Data, directory: String, completion: @escaping (Result<String, Error>) -> Void) {
        let imagePath = "\(directory)/\(UUID().uuidString).png"
        let storageRef = Storage.storage().reference().child(imagePath)
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        storageRef.putData(data, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.lastPathComponent))
                } else {
                    let err = NSError(domain: "UploadErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                    completion(.failure(err))
                }
            }
        }
    }
    
    static func uploadImage(data: Data, directory: String) async -> Result<String, Error> {
        let storageRef = Storage.storage().reference()
        let imagePath = "\(directory)/\(UUID().uuidString).png"
        let imageRef = storageRef.child(imagePath)
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        do {
            _ = try await imageRef.putDataAsync(data, metadata: metadata)
            let url = try await imageRef.downloadURL()
            return .success(url.lastPathComponent)
        } catch {
            return .failure(error)
        }
    }

    static func uploadResizedPhotos(itemImage: UIImage?) async -> (original: String?, thumbnail: String?) {
        guard let itemImage = itemImage else {
            return (nil, nil)
        }
        
        let thumbnailSize: CGFloat = 150
        let originalSize: CGFloat = 300
        
        guard let thumbnailImage = resizedImageToSquare(itemImage, size: thumbnailSize),
              let thumbnailData = thumbnailImage.pngData(),
              let originalImage = resizedImageToSquare(itemImage, size: originalSize),
              let originalData = originalImage.pngData() else {
            return (nil, nil)
        }
        
        let thumbnailResult = await uploadImage(data: thumbnailData, directory: "items_images/thumbnails")
        let originalResult = await uploadImage(data: originalData, directory: "items_images")
        
        switch (originalResult, thumbnailResult) {
        case (.success(let originalURL), .success(let thumbnailURL)):
            return (originalURL, thumbnailURL)
        default:
            return (nil, nil)
        }
    }
    
    /// Функция для изменения размера изображения до заданного квадратного размера.
    static func resizedImageToSquare(_ image: UIImage, size: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size, height: size)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
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
