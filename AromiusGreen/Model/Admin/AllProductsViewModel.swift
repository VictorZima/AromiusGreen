//
//  AllProductsViewModel.swift
//  AromiusGreen
//
//  Created by VictorZima on 16/11/2024.
//

import Foundation

class AllProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var manufacturers: [ManufacturerSummary] = []
    
    private var dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    func fetchProducts() {
        self.products = dataManager.products
    }
    
    func fetchManufacturers() {
        self.manufacturers = dataManager.manufacturers.map { manufacturer in
            ManufacturerSummary(id: manufacturer.id ?? "", title: manufacturer.title, logo: manufacturer.logo)
        }
    }
}
 
