//
//  AddProductLineView.swift
//  AromiusGreen
//
//  Created by VictorZima on 25/10/2024.
//

import SwiftUI

struct AddProductLineView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    var manufacturer: Manufacturer
    
    @State private var title: String = ""
    @State private var lineDescription: String = ""
    @State private var logo: String = ""
    @State private var isShow: Bool = true
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    
    var body: some View {
        AdminView {
            Form {
                TextField("Name", text: $title)
                TextField("Description", text: $lineDescription)
                Section {
                    Toggle(isOn: $isShow) {
                        Text("Показывать продуктовую линейку")
                    }
                }
                if isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Add Product Line")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveProductLine()
                }
                    .disabled(!isFormValid() || isLoading)
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Произошла ошибка"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func isFormValid() -> Bool {
        return !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveProductLine() {
        guard isFormValid() else {
            self.errorMessage = "Пожалуйста, введите название."
            self.showAlert = true
            return
        }
        
        isLoading = true
        
        let newProductLine = ProductLine(
            title: title,
            lineDescription: lineDescription,
            logo: logo,
            isShow: isShow,
            manufacturerId: manufacturer.id ?? ""
        )
        
        dataManager.addProductLine(newProductLine, to: manufacturer) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let productLine):
                    print("Продуктовая линейка добавлена с ID: \(productLine.id ?? "N/A")")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}

