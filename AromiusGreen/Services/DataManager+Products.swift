//
//  DataManager+Products.swift
//  AromiusGreen
//
//  Created by VictorZima on 15/01/2025.
//

import Firebase
import FirebaseFirestoreSwift
import SwiftUI

extension DataManager {
    
    func fetchProductById(productId: String, completion: @escaping (Product?) -> Void) {
        let docRef = db.collection("items").document(productId)
        
        docRef.getDocument { document, error in
            if let error = error {
                debugLog("Error fetching product: \(error.localizedDescription)")
                completion(nil)
            } else if let document = document, document.exists {
                do {
                    let product = try document.data(as: Product.self)
                    completion(product)
                } catch {
                    debugLog("Error decoding product: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                debugLog("Product not found")
                completion(nil)
            }
        }
    }
    
    func addProduct(_ product: Product, completion: @escaping (Result<Product, Error>) -> Void) {
        let docRef = db.collection("items").document()
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
}
