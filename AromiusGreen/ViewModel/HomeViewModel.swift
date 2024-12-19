//
//  HomeViewModel.swift
//  AromiusGreen
//
//  Created by VictorZima on 09/11/2024.
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var selectedCategory: String? = "All"
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    
    private var dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: DataManager) {
            self.dataManager = dataManager
            loadInitialData()
            
            dataManager.$isDataLoaded
                .sink { [weak self] isLoaded in
                    if isLoaded {
                        self?.loadInitialData() // Загружаем данные после флага isDataLoaded
                    }
                }
                .store(in: &cancellables)
        }
        
        func loadInitialData() {
            products = dataManager.products
            categories = dataManager.categories
        }
    
    var filteredProducts: [Product] {
        if selectedCategory == "All" || selectedCategory == nil {
            return products
        } else if let selectedCategory = selectedCategory {
            return products.filter { $0.categoryIds.contains(selectedCategory) }
        } else {
            return []
        }
    }
    
    func selectCategory(_ categoryId: String) {
        selectedCategory = categoryId
    }
}
