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
        
        print("Fetching product with ID: \(productId.uuidString)")
        
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
}
