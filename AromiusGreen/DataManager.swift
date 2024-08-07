//
//  DataManager.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI
import Firebase
import FirebaseStorage

class DataManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    private var productsListener: ListenerRegistration?
    
    init() {
        fetchCategories()
        addProductsListener()
    }
    
    deinit {
        productsListener?.remove()
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
                        let title = data["title"] as? String ?? ""
                        let descr = data["description"] as? String ?? ""
                        let value = data["value"] as? String ?? ""
                        let image = data["image"] as? String ?? ""
                        let thumbnailImage = data["thumbnailImage"] as? String ?? ""
                        let price = data["price"] as? Int ?? 0
                        let categories = data["categoryIds"] as? [String] ?? []
                        let manufactureId = data["manufactureId"] as? Int ?? 0
                        let manufactureName = data["manufactureName"] as? String ?? ""
                        let productLineId = data["productLineId"] as? Int ?? 0
                        let productLineName = data["productLineName"] as? String ?? ""
                        let product = Product(name: title, descr: descr, value: value, categories: categories, manufactureId: manufactureId, manufactureName: manufactureName, productLineId: productLineId, productLineName: productLineName,image: image, thumbnailImage: thumbnailImage, price: price)
                        
                        self.products.append(product)
                    }
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
}
