//
//  OldAddProductView.swift
//  AromiusGreen
//
//  Created by VictorZima on 10/09/2024.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct OldAddProductView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var title: String = ""
    @State private var barcode: String = ""
    @State private var productDescription: String = ""
    @State private var value: String = ""
    @State private var categoryIds: [String] = []
    @State private var selectedManufacturer: Manufacturer?
    @State private var selectedProductLine: ProductLine?
    @State private var price: String = ""
    @State private var purchasePrice: String = ""
    @State private var image: String = ""
    @State private var thumbnailImage: String = ""
    @State private var isAvailable: Bool = true
    @State private var isLoading: Bool = false
    @State private var showProductLines: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    
    var body: some View {
        AdminView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Title", text: $title)
                    TextField("Barcode", text: $barcode)
                    TextField("Description", text: $productDescription)
                    TextField("Value", text: $value)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Закупочная цена", text: $purchasePrice)
                        .keyboardType(.decimalPad)
                }
                
                // Связь с производителем и продуктовой линейкой
                //                Section(header: Text("Связь")) {
                //                    Picker("Производитель", selection: $selectedManufacturer) {
                //                        Text("Выберите производителя").tag(nil as Manufacturer?)
                //                        ForEach(dataManager.manufacturers) { manufacturer in
                //                            Text(manufacturer.title).tag(Optional(manufacturer))
                //                        }
                //                    }
                //                    .onChange(of: selectedManufacturer) { _ in
                //                        selectedProductLine = nil
                //                        showProductLines = false
                //                        if let manufacturer = selectedManufacturer {
                //                            fetchProductLines(for: manufacturer)
                //                        }
                //                    }
                //
                //                    if showProductLines {
                //                        Picker("Продуктовая линейка", selection: $selectedProductLine) {
                //                            Text("Выберите продуктовую линейку").tag(nil as ProductLine?)
                //                            ForEach(dataManager.productLines.filter { $0.manufacturerID == selectedManufacturer?.id }) { productLine in
                //                                Text(productLine.title).tag(Optional(productLine))
                //                            }
                //                        }
                //                    }
                //                }
                
                // Доступность продукта
//                Section {
//                    Toggle(isOn: $isAvailable) {
//                        Text("Доступен")
//                    }
//                }
                
                // Индикатор загрузки
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
            .navigationTitle("Добавить Продукт")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveProduct()
                }
                    .disabled(!isFormValid() || isLoading)
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Произошла ошибка"), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                loadManufacturers()
            }
        }
    }
    
    private func isFormValid() -> Bool {
        guard
            !title.trimmingCharacters(in: .whitespaces).isEmpty,
            selectedManufacturer != nil,
            selectedProductLine != nil,
            let priceValue = Double(price),
            priceValue >= 0,
            !image.trimmingCharacters(in: .whitespaces).isEmpty,
            !thumbnailImage.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return false
        }
        return true
    }
    
    private func loadManufacturers() {
        dataManager.fetchManufacturers { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showAlert = true
            }
        }
    }
    
    private func fetchProductLines(for manufacturer: Manufacturer) {
        isLoading = true
        dataManager.fetchProductLines { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(_):
                    self.showProductLines = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    private func saveProduct() {
        guard isFormValid(),
              let priceValue = Double(price),
              let purchasePriceValue = Double(purchasePrice.isEmpty ? "0" : purchasePrice),
              let manufacturer = selectedManufacturer,
              let productLine = selectedProductLine else {
            self.errorMessage = "Пожалуйста, заполните все обязательные поля корректно."
            self.showAlert = true
            return
        }
        
        isLoading = true
        
        let manufacturerSummary = ManufacturerSummary(
            id: manufacturer.id ?? "",
            title: manufacturer.title,
            logo: manufacturer.logo
        )
        
        let productLineSummary = ProductLineSummary(
            id: productLine.id ?? "",
            title: productLine.title,
            logo: productLine.logo
        )
        
        let newProduct = Product(
            title: title,
            barcode: barcode,
            productDescription: productDescription,
            value: value.isEmpty ? nil : value,
            categoryIds: categoryIds,
            manufacturer: manufacturerSummary,
            productLine: productLineSummary,
            image: image,
            thumbnailImage: thumbnailImage,
            price: priceValue,
            purchasePrice: purchasePriceValue == 0 ? nil : purchasePriceValue
        )
        
        dataManager.addProduct(newProduct) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(_):
                    print("Продукт успешно добавлен")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}

//struct AddProductView_Previews: PreviewProvider {
//    static var previews: some View {
//        OldAddProductView()
//            .environmentObject(DataManager())
//    }
//}

//struct AddProductView: View {
//    @EnvironmentObject var authManager: AuthManager
//    @EnvironmentObject var dataManager: DataManager
//    
//    @State private var checkboxStates: [String: Bool] = [:]
//    @State private var title = ""
//    @State private var barcode = ""
//    @State private var selectedManufacturer: String?
//    @State private var selectedProductLine: String?
//    @State private var image = ""
//    @State private var price: Double = 0.0
//    @State private var purchasePrice: Double = 0.0
//    @State private var value = ""
//    @State private var productDescription = ""
//    @State private var selectedCategories: [String] = []
//    @State private var itemImage: UIImage?
//    @State private var photosPickerItem: PhotosPickerItem?
//    @State private var isSaving = false
//    @State private var showingImageEditor = false
//    @State private var isLoading: Bool = false
//    @State private var showProductLines: Bool = false
//    @State private var errorMessage: String?
//    @State private var showAlert: Bool = false
//    
//    var body: some View {
//        if authManager.currentUser?.isAdmin == true {
//            Form {
//                Section(header: Text("Image")) {
//                    PhotosPicker(selection: $photosPickerItem, matching: .images) {
//                        Image(uiImage: itemImage ?? UIImage(resource: .noPhoto))
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 200, height: 200)
//                            .clipShape(Rectangle())
//                            .cornerRadius(10)
//                            .frame(maxWidth: .infinity)
//                    }
//                    .onChange(of: photosPickerItem) { newItem in
//                        if let newItem = newItem {
//                            Task {
//                                if let data = try? await newItem.loadTransferable(type: Data.self),
//                                   let image = UIImage(data: data) {
//                                    itemImage = image
//                                }
//                            }
//                        }
//                    }
//                    .sheet(isPresented: $showingImageEditor) {
//                        ImageEditorView(image: $itemImage)
//                    }
//                    
//                    if itemImage != nil {
//                        Button("Edit Image") {
//                            showingImageEditor = true
//                        }
//                        .padding()
//                    }
//                }
//
//                Section(header: Text("Info")) {
//                    TextField("Title", text: $title)
//                    HStack {
//                        TextField("Barcode", text: $barcode)
//                        Text("*")
//                            .foregroundStyle(.red)
//                            .font(.title3)
//                    }
//                    
//                    TextField("Description", text: $productDescription)
//                    TextField("Price", value: $price, format: .number)
//                        .keyboardType(.decimalPad)
//                    TextField("Purchase Price", value: $purchasePrice, format: .number)
//                        .keyboardType(.decimalPad)
//                    TextField("Value (ml)", text: $value)
//                }
//                
//                Section(header: Text("Info")) {
//                    List {
//                        ForEach(dataManager.categories, id: \.id) { category in
//                            if let categoryId = category.id {
//                                CheckboxField(id: categoryId, label: category.title) { id, isChecked in
//                                    if isChecked {
//                                        selectedCategories.append(id)
//                                    } else {
//                                        selectedCategories.removeAll { $0 == id }
//                                    }
//                                }
//                            } else {
//                                Text("Категория без идентификатора")
//                            }
//                        }
//                    }
//                }
//                
//                Section(header: Text("Связь")) {
//                    Picker("Производитель", selection: $selectedManufacturer) {
//                        Text("Выберите производителя").tag(nil as Manufacturer?)
//                        ForEach(dataManager.manufacturers) { manufacturer in
//                            Text(manufacturer.title).tag(Optional(manufacturer))
//                        }
//                    }
//                    .onChange(of: selectedManufacturer) { _ in
//                        selectedProductLine = nil
//                        showProductLines = false
//                        if let manufacturer = selectedManufacturer {
//                            fetchProductLines(for: manufacturer)
//                        }
//                    }
//                    
//                    if showProductLines {
//                        Picker("Продуктовая линейка", selection: $selectedProductLine) {
//                            Text("Выберите продуктовую линейку").tag(nil as ProductLine?)
//                            ForEach(dataManager.productLines.filter { $0.manufacturerID == selectedManufacturer?.id }) { productLine in
//                                Text(productLine.title).tag(Optional(productLine))
//                            }
//                        }
//                    }
//                }
//            }
//            
//            .navigationTitle("Add new item")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        Task {
//                            isSaving = true
//                            await addProduct()
//                            isSaving = false
//                        }
//                    }) {
//                        Text("Save")
//                    }
//                    .disabled(barcode.isEmpty || title.isEmpty || itemImage == nil)
//                }
//            }
//            .onAppear {
////                if let firstManufacturerId = dataManager.manufacturers.first?.id {
////                    selectedManufacturerId = firstManufacturerId
////                }
////                if let firstProductLineId = dataManager.productLines.first?.id {
////                    selectedProductLineId = firstProductLineId
////                }
//            }
//        } else {
//            Text("Access Denied")
//                .font(.title)
//                .foregroundColor(.red)
//        }
//    }
//    
//    private func uploadPhotos() async -> (String?, String?) {
//        guard let itemImage = itemImage else {
//            return (nil, nil)
//        }
//        
//        let thumbnailSize: CGFloat = 150
//        let imageSize: CGFloat = 300
//        
//        guard let thumbnailImage = resizedImageToSquare(itemImage, size: thumbnailSize),
//              let thumbnailData = thumbnailImage.pngData(),
//              let originalImage = resizedImageToSquare(itemImage, size: imageSize),
//              let originalData = originalImage.pngData() else {
//            return (nil, nil)
//        }
//        
//        let storageRef = Storage.storage().reference()
//        let thumbnailPath = "items_images/thumbnails/\(UUID().uuidString).png"
//        let originalPath = "items_images/\(UUID().uuidString).png"
//        do {
//            let thumbnailRef = storageRef.child(thumbnailPath)
//            let _ = try await thumbnailRef.putDataAsync(thumbnailData)
//            let thumbnailURL = try await thumbnailRef.downloadURL()
//            
//            let originalRef = storageRef.child(originalPath)
//            let _ = try await originalRef.putDataAsync(originalData)
//            let originalURL = try await originalRef.downloadURL()
//            
//            return (originalURL.lastPathComponent, thumbnailURL.lastPathComponent)
//        } catch {
//            print("Ошибка при загрузке изображений: \(error)")
//            return (nil, nil)
//        }
//    }
//    
//    func resizedImageToSquare(_ image: UIImage, size: CGFloat) -> UIImage? {
//        let newSize = CGSize(width: size, height: size)
//        let renderer = UIGraphicsImageRenderer(size: newSize)
//        return renderer.image { _ in
//            image.draw(in: CGRect(origin: .zero, size: newSize))
//        }
//    }
//    
//    private func loadManufacturers() {
//            dataManager.fetchManufacturers { result in
//                switch result {
//                case .success(_):
//                    // Успешно загружены производители
//                    break
//                case .failure(let error):
//                    self.errorMessage = error.localizedDescription
//                    self.showAlert = true
//                }
//            }
//        }
//        
//        // Загрузка продуктовых линеек для выбранного производителя
//        private func fetchProductLines(for manufacturer: Manufacturer) {
//            isLoading = true
//            dataManager.fetchProductLines { result in
//                DispatchQueue.main.async {
//                    isLoading = false
//                    switch result {
//                    case .success(_):
//                        self.showProductLines = true
//                    case .failure(let error):
//                        self.errorMessage = error.localizedDescription
//                        self.showAlert = true
//                    }
//                }
//            }
//        }
//    
//    private func addProduct() async {
//        let (imageUrl, thumbnailUrl) = await uploadPhotos()
//        
//        guard let imageUrl = imageUrl, let thumbnailUrl = thumbnailUrl else {
//            print("Ошибка при загрузке изображений")
//            return
//        }
//        
//        guard let selectedManufacturerId = selectedManufacturerId else {
//            print("Ошибка: Не выбран производитель")
//            return
//        }
//        
////        guard let selectedProductLineId = selectedProductLineId else {
////            print("Ошибка: Не выбрана линейка продуктов")
////            return
////        }
//        
//        guard let manufacturer = dataManager.manufacturers.first(where: { $0.id == selectedManufacturerId }) else {
//            print("Ошибка: Производитель не найден")
//            return
//        }
//        
////        let productLineName = selectedProductLineId.flatMap { id in
////            dataManager.productLines?.first(where: { $0.id == id })?.title
////        }
////        
//        let newItem = Product(
//            title: title,
//            barcode: barcode,
//            productDescription: productDescription,
//            value: value.isEmpty ? nil : value,
//            categoryIds: selectedCategories,
////            manufacturerId: selectedManufacturerId,
////            manufacturerName: manufacturer.title,
////            productLineId: selectedProductLineId,
////            productLineName: productLineName,
//            image: imageUrl,
//            thumbnailImage: thumbnailUrl,
//            price: price,
//            purchasePrice: purchasePrice
//        )
//        print("Попытка добавить продукт: \(newItem)")
//        dataManager.addProduct(item: newItem)
//
//    }
//}

struct CheckboxField: View {
    let id: String
    let label: String
    let callback: (String, Bool)->()
    @State var isChecked: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: isChecked ? "checkmark.square" : "square")
            Text(label)
        }
        .onTapGesture {
            self.isChecked.toggle()
            self.callback(id, self.isChecked)
        }
    }
}

#Preview {
    OldAddProductView()
        .environmentObject(AuthManager())
        .environmentObject(DataManager())
}
