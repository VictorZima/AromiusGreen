//
//  AddManufacturerView.swift
//  AromiusGreen
//
//  Created by VictorZima on 25/10/2024.
//

import SwiftUI

struct AddManufacturerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var title: String = ""
    @State private var manufacturerDescription: String = ""
    @State private var logo: String = ""
    @State private var isShow: Bool = true
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    
    var body: some View {
        AdminView {
            Form {
                TextField("Title", text: $title)
                TextField("Description", text: $manufacturerDescription)
                Section {
                    Toggle(isOn: $isShow) {
                        Text("Show Manufacturer")
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
            .navigationTitle("Add Manufacturer")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    saveManufacturer()
                }
                    .disabled(!isFormValid() || isLoading)
            )
        }
    }
    
    private func isFormValid() -> Bool {
        return !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func saveManufacturer() {
        guard isFormValid() else {
            self.errorMessage = "Пожалуйста, введите название."
            self.showAlert = true
            return
        }
        
        isLoading = true
        
        let newManufacturer = Manufacturer(
            title: title,
            manufacturerDescription: manufacturerDescription,
            logo: logo,
            isShow: isShow
        )
        
        dataManager.addManufacturer(newManufacturer) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(_):
                    print("Производитель успешно добавлен")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}

#Preview {
    AddManufacturerView()
        .environmentObject(DataManager())
}
