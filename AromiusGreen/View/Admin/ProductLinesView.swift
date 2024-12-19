//
//  ProductLinesView.swift
//  AromiusGreen
//
//  Created by VictorZima on 25/10/2024.
//

import SwiftUI

struct ProductLinesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var productLines: [ProductLine] = []
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var errorMessage: String?
    
    var manufacturer: Manufacturer
    
    var body: some View {
        AdminView {
            List {
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if !productLines.isEmpty {
                    ForEach(productLines, id: \.id) { productLine in
                        VStack(alignment: .leading) {
                            Text(productLine.title)
                                .font(.headline)
                            if let lineDescription =  productLine.lineDescription {
                                Text(lineDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                } else {
                    Text("У этого производителя пока нет продуктовых линеек.")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle(manufacturer.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AddProductLineView(manufacturer: manufacturer)
                    } label: {
                        Text("Add New")
                    }
                }
            }
            .onAppear {
                loadProductLines()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Ошибка"), message: Text(errorMessage ?? "Произошла ошибка"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func loadProductLines() {
        isLoading = true
        dataManager.fetchProductLines { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let allProductLines):
                    // Фильтруем продуктовые линейки по текущему производителю
                    self.productLines = allProductLines.filter { $0.manufacturerId == manufacturer.id }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}

//#Preview {
//    ProductLinesView()
//}
