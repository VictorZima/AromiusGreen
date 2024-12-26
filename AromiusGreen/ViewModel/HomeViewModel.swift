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
    @Published var isDataLoaded: Bool = false
    
    private var dataManager: DataManager?
    private var cancellables = Set<AnyCancellable>()
    
    init() { }
    
    func setup(with dataManager: DataManager) {
        self.dataManager = dataManager
        fetchInitialData()
        
        // Подписка на изменения продуктов
        dataManager.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                self?.products = products
                print("HomeViewModel: Продукты обновлены: \(products.count)")
                self?.checkIfDataLoaded()
            }
            .store(in: &cancellables)
    }
    
    func fetchInitialData() {
        guard let dataManager = dataManager else {
            print("HomeViewModel: DataManager не установлен")
            return
        }
        
        // Загрузка категорий один раз
        dataManager.fetchCategories { [weak self] fetchedCategories in
            DispatchQueue.main.async {
                self?.categories = fetchedCategories
                print("HomeViewModel: Категории обновлены: \(fetchedCategories.count)")
                self?.checkIfDataLoaded()
            }
        }
        
        // Присвоение текущих продуктов из DataManager
        self.products = dataManager.products
        print("HomeViewModel: Продукты загружены: \(products.count)")
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
    
    func selectCategory(_ categoryId: String?) {
        selectedCategory = categoryId ?? "All"
        print("HomeViewModel: Выбрана категория: \(selectedCategory ?? "All")")
    }
    
    private func checkIfDataLoaded() {
        if !categories.isEmpty && !products.isEmpty {
            isDataLoaded = true
            print("HomeViewModel: Все данные загружены")
        }
    }
}
