//
//  AllProductsView.swift
//  AromiusGreen
//
//  Created by VictorZima on 10/09/2024.
//

import SwiftUI

struct AllProductsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var viewModel: AllProductsViewModel
    
    @State private var selectedManufacturerId: String? = nil
    
    init(dataManager: DataManager) {
        _viewModel = StateObject(wrappedValue: AllProductsViewModel(dataManager: dataManager))
    }
    
    var body: some View {
        AdminView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        CustomActionButton(title: "All", widthSize: .small) {
                            selectedManufacturerId = nil
                        }
                        
                        ForEach(viewModel.manufacturers, id: \.id) { manufacturer in
                            CustomActionButton(title: manufacturer.title, widthSize: .small) {
                                selectedManufacturerId = manufacturer.id
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                List {
                    ForEach(filteredProducts) { product in
                        VStack(alignment: .leading) {
                            Text(product.title)
                                .font(.headline)
                            Text(product.barcode)
                                .font(.subheadline)
                            Text(product.value ?? "")
                                .font(.subheadline)
                                .foregroundStyle(Color.gray)
                            HStack {
                                Text("\(product.price.formattedPrice()) ₪")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                                
                                Text(product.purchasePrice?.formattedPrice() ?? "N/A")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            
            .navigationTitle("All Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink{
                        AddProductView()
                            
                    } label: {
                        Text("Add New")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchManufacturers()
            viewModel.fetchProducts()
        }
    }
    
    private var filteredProducts: [Product] {
        if let manufacturerId = selectedManufacturerId {
            return viewModel.products.filter { $0.manufacturer?.id == manufacturerId }
        } else {
            return viewModel.products
        }
    }
}

#Preview {
    AllProductsView(dataManager: DataManager())
        .environmentObject(AuthManager())
        .environmentObject(DataManager())
}
