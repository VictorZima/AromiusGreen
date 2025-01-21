//
//  AddProductViewModel.swift
//  AromiusGreen
//
//  Created by VictorZima on 17/11/2024.
//

import SwiftUI
import Combine

@MainActor
class AddProductViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var barcode: String = ""
    @Published var productDescription: String?
    @Published var value: String = ""
    @Published var priceString: String = ""
    @Published var purchasePriceString: String = ""
    @Published var selectedCategoryIds: [String] = []
    @Published var selectedManufacturerId: String? = nil
    @Published var selectedManufacturerName: String? = nil
    
    @Published var availableProductLines: [ProductLine] = []
    @Published var selectedProductLineId: String? = nil
    @Published var selectedProductLineName: String? = nil
    
    @Published var isSaving: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var productImageData: Data? = nil
    
    var dataManager: DataManager?
    
    func saveProduct() {
        guard let _ = dataManager else {
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
        
        guard let _ = selectedManufacturerId,
              let _ = selectedManufacturerName else {
            alertMessage = "Please select a manufacturer."
            showAlert = true
            return
        }
        
        let purchasePrice = Double(purchasePriceString)

        if let imageData = productImageData, let image = UIImage(data: imageData) {
            Task {
                let result = await DataManager.uploadResizedPhotos(itemImage: image)
                DispatchQueue.main.async { [weak self] in
                    if let originalUrl = result.original, let thumbnailUrl = result.thumbnail {
                        self?.createProduct(with: originalUrl, thumbnail: thumbnailUrl, purchasePrice: purchasePrice)
                    } else {
                        self?.isSaving = false
                        self?.alertMessage = "Error: Failed to upload product image."
                        self?.showAlert = true
                    }
                }
            }
        } else {
            createProduct(with: nil, thumbnail: nil, purchasePrice: purchasePrice)
        }
    }
    
    private func createProduct(with imageUrl: String?, thumbnail: String?, purchasePrice: Double?) {
        let newProduct = Product(
            id: nil,
            title: title,
            barcode: barcode,
            productDescription: productDescription?.isEmpty == false ? productDescription : nil,
            value: value.isEmpty ? nil : value,
            categoryIds: selectedCategoryIds,
            manufacturer: ManufacturerSummary(id: selectedManufacturerId ?? "", title: selectedManufacturerName ?? "", logo: nil),
            productLine: ProductLineSummary(id: selectedProductLineId ?? "", title: selectedProductLineName ?? "", logo: nil),
            image: imageUrl,
            thumbnailImage: thumbnail,
            price: Double(priceString) ?? 0.0,
            purchasePrice: purchasePrice
        )
        
        dataManager?.addProduct(newProduct) { [weak self] result in
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
