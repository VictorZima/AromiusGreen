//
//  AddProductView.swift
//  AromiusGreen
//
//  Created by VictorZima on 16/11/2024.
//

import SwiftUI

struct AddProductView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var viewModel: AddProductViewModel

    init() {
        _viewModel = StateObject(wrappedValue: AddProductViewModel())
    }
    
    var body: some View {
        AdminView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Title", text: $viewModel.title)
                        .autocapitalization(.words)
                    
                    TextField("Barcode", text: $viewModel.barcode)
                        .keyboardType(.numberPad)
                    
                    TextField("Description", text: Binding(
                        get: { viewModel.productDescription ?? "" },
                        set: { viewModel.productDescription = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Section(header: Text("Prices")) {
                    TextField("Price", text: Binding(
                        get: { viewModel.priceString },
                        set: { viewModel.priceString = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    
                    TextField("Purchase Price", text: Binding(
                        get: { viewModel.purchasePriceString },
                        set: { viewModel.purchasePriceString = $0 }
                    ))
                    .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Categories")) {
                    ForEach(dataManager.categories, id: \.id) { category in
                        MultipleSelectionRow(title: category.title, isSelected: viewModel.selectedCategoryIds.contains(category.id ?? "")) {
                            if let id = category.id {
                                if viewModel.selectedCategoryIds.contains(id) {
                                    viewModel.selectedCategoryIds.removeAll { $0 == id }
                                } else {
                                    viewModel.selectedCategoryIds.append(id)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Manufacturer")) {
                    Picker("Select Manufacturer", selection: Binding(
                        get: { viewModel.selectedManufacturerId },
                        set: { newValue in
                            viewModel.selectedManufacturerId = newValue
                            if let id = newValue,
                               let manufacturer = dataManager.manufacturers.first(where: { $0.id == id }) {
                                viewModel.selectedManufacturerName = manufacturer.title
                            } else {
                                viewModel.selectedManufacturerName = nil
                            }
                        }
                    )) {
                        Text("Select Manufacturer").tag(String?.none)
                        ForEach(dataManager.manufacturers) { manufacturer in
                            Text(manufacturer.title).tag(Optional(manufacturer.id))
                        }
                    }
                }
            }
            .navigationTitle("Add new product")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveProduct()
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Result"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                viewModel.dataManager = dataManager
            }
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack {
                Text(self.title)
                Spacer()
                if self.isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
