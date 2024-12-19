//
//  AddProductViewModel.swift
//  AromiusGreen
//
//  Created by VictorZima on 17/11/2024.
//

import SwiftUI

class AddProductViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var barcode: String = ""
    @Published var productDescription: String?
    @Published var value: String = ""
    @Published var priceString: String = ""
    @Published var purchasePriceString: String = ""
    @Published var selectedCategoryIds: [String] = []
//    @Published var selectedManufacturer: ManufacturerSummary? = nil
    @Published var selectedManufacturerId: String? = nil
    @Published var selectedManufacturerName: String? = nil
    
    @Published var availableProductLines: [ProductLine] = []
    @Published var selectedProductLineId: String? = nil
    @Published var selectedProductLineName: String? = nil
    
    @Published var isSaving: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    var dataManager: DataManager?
    
    func saveProduct() {
        guard let dataManager = dataManager else {
            alertMessage = "Data Manager is not initialized."
            showAlert = true
            return
        }
        
        guard !title.isEmpty,
              let price = Double(priceString),
              price > 0 else {
            alertMessage = "Please fill in all required fields correctly."
            showAlert = true
            return
        }
        
        guard let manufacturerId = selectedManufacturerId,
              let manufacturerName = selectedManufacturerName else {
            alertMessage = "Please select a manufacturer."
            showAlert = true
            return
        }
        
        let purchasePrice = Double(purchasePriceString)
        
        let newProduct = Product(
            id: nil,
            title: title,
            barcode: barcode,
            productDescription: productDescription?.isEmpty == false ? productDescription : nil,
            value: value.isEmpty ? nil : value,
            categoryIds: selectedCategoryIds,
            manufacturer: ManufacturerSummary(id: manufacturerId, title: manufacturerName, logo: ""),
            productLine: nil,
            image: nil,
            thumbnailImage: nil,
            price: price,
            purchasePrice: purchasePrice
        )
        
        isSaving = true
        dataManager.addProduct(newProduct) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSaving = false
                switch result {
                case .success:
                    self?.alertMessage = "Product successfully added!"
                    self?.resetForm()
                case .failure(let error):
                    self?.alertMessage = "Error: \(error.localizedDescription)"
                }
                self?.showAlert = true
            }
        }
    }
    
    private func resetForm() {
        title = ""
        barcode = ""
        productDescription = ""
        value = ""
        priceString = ""
        purchasePriceString = ""
        selectedCategoryIds = []
        selectedManufacturerId = nil
        selectedManufacturerName = nil
    }
}
