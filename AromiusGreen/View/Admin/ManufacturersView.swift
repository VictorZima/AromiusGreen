//
//  ManufacturersView.swift
//  AromiusGreen
//
//  Created by VictorZima on 23/10/2024.
//

import SwiftUI

struct ManufacturersView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    
    var body: some View {
        AdminView {
            List {
                ForEach(dataManager.manufacturers, id: \.id) { manufacturer in
                    VStack(alignment: .leading) {
                        NavigationLink(destination: ProductLinesView(manufacturer: manufacturer)) {
                            Text(manufacturer.title)
                                .font(.headline)
                                .bold()
                        }
                    }
                }
            }
            .navigationTitle("Manufacturers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AddManufacturerView()
                    } label: {
                        Text("Add New")
                    }
                }
            }
            .onAppear {
                loadManufacturers()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Произошла ошибка"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func loadManufacturers() {
        isLoading = true
        dataManager.fetchManufacturers { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}
