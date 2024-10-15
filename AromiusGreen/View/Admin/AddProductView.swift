//
//  AddProductView.swift
//  AromiusGreen
//
//  Created by VictorZima on 10/09/2024.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct AddProductView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    @State private var checkboxStates: [String: Bool] = [:]
    @State private var title = ""
    @State private var barcode = ""
    @State private var selectedManufactureId: String? = nil
    @State private var selectedProductLineId: String? = nil
    @State private var image = ""
    @State private var price: Double = 0.0
    @State private var purchasePrice: Double = 0.0
    @State private var value = ""
    @State private var description = ""
    @State private var selectedCategories: [String] = []
    
    @State private var itemImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    
    @State private var isSaving = false
    @State private var showingImageEditor = false
    
    var body: some View {
        if authManager.currentUser?.isAdmin == true {
            Form {
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    Image(uiImage: itemImage ?? UIImage(resource: .defaultItemPhoto))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(.rect)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                }
                .onChange(of: photosPickerItem) { newItem in
                    if let newItem = newItem {
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                itemImage = image
                            }
                        }
                    }
                }
                //            .onChange(of: photosPickerItem) { _, _ in
                //                Task {
                //                    if let photosPickerItem,
                //                       let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                //                        if let image = UIImage(data: data) {
                //                            itemImage = image
                //                            showingImageEditor = true
                //                        }
                //                    }
                //                    photosPickerItem = nil
                //                }
                //            }
                
                //            .onChange(of: photosPickerItem) { newItem in // Обработчик изменений для photosPickerItem
                //                       if let newItem = newItem {
                //                           Task {
                //                               if let data = try? await newItem.loadTransferable(type: Data.self),
                //                                  let image = UIImage(data: data) {
                //                                   itemImage = image
                //                               }
                //                           }
                //                       }
                //                   }
                
                .sheet(isPresented: $showingImageEditor) {
                    ImageEditorView(image: $itemImage)
                }
                
                if itemImage != nil {
                    Button("Edit Image") {
                        showingImageEditor = true
                    }
                    .padding()
                }
                
                TextField("Title", text: $title)
                HStack {
                    TextField("Barcode", text: $barcode)
                    Text("*")
                        .foregroundStyle(.red)
                        .font(.title3)
                }
                
                Picker("Manufacture", selection: $selectedManufactureId) {
                    ForEach(dataManager.manufacturies, id: \.id) { manufacture in
                        Text(manufacture.title).tag(manufacture.id)
                    }
                }
                Picker("ProductLine", selection: $selectedProductLineId) {
                    ForEach(dataManager.productLines, id: \.id) { productLine in
                        Text(productLine.title).tag(productLine.id)
                    }
                }
                
                TextField("Description", text: $description)
                TextField("Price", value: $price, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Purchase Price", value: $purchasePrice, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Value (ml)", text: $value)
                List {
                    ForEach(dataManager.categories, id: \.id) { category in
                        if let categoryId = category.id {
                            CheckboxField(id: categoryId, label: category.title) { id, isChecked in
                                if isChecked {
                                    selectedCategories.append(id)
                                } else {
                                    selectedCategories.removeAll { $0 == id }
                                }
                            }
                        } else {
                            Text("Категория без идентификатора")
                        }
                    }
                }
                
                if isSaving {
                    ProgressView()
                } else {
                    Button {
                        Task {
                            isSaving = true
                            await addProduct()
                            isSaving = false
                        }
                        
                    } label: {
                        Text("Save")
                    }
                    .disabled(barcode.isEmpty)
                }
            }
            .navigationTitle("Add new item")
            //        }
            .onAppear {
                if let firstManufactureId = dataManager.manufacturies.first?.id {
                    selectedManufactureId = firstManufactureId
                }
                if let firstProductLineId = dataManager.productLines.first?.id {
                    selectedProductLineId = firstProductLineId
                }
            }
            
            
        } else {
            Text("Access Denied")
                .font(.title)
                .foregroundColor(.red)
        }
    }
    
    private func uploadPhotos() async -> (String?, String?) {
        guard let itemImage = itemImage else {
            return (nil, nil)
        }
        
        let thumbnailSize: CGFloat = 150
        let imageSize: CGFloat = 300
        
        guard let thumbnailImage = resizedImageToSquare(itemImage, size: thumbnailSize),
              let thumbnailData = thumbnailImage.pngData(),
              let originalImage = resizedImageToSquare(itemImage, size: imageSize),
              let originalData = originalImage.pngData() else {
            return (nil, nil)
        }
        //        guard let thumbnailImage = resizedImage(itemImage, width: thumbnailWidth),
        //              let thumbnailData = thumbnailImage.pngData() else {
        //            return (nil, nil)
        //        }
        //
        //        guard let originalImage = resizedImage(itemImage, width: imageWidth),
        //              let originalData = originalImage.pngData() else {
        //            return (nil, nil)
        //        }
        
        let storageRef = Storage.storage().reference()
        let thumbnailPath = "items_images/thumbnails/\(UUID().uuidString).png"
        let originalPath = "items_images/\(UUID().uuidString).png"
        do {
            let thumbnailRef = storageRef.child(thumbnailPath)
            let _ = try await thumbnailRef.putDataAsync(thumbnailData)
            let thumbnailURL = try await thumbnailRef.downloadURL()
            
            let originalRef = storageRef.child(originalPath)
            let _ = try await originalRef.putDataAsync(originalData)
            let originalURL = try await originalRef.downloadURL()
            
            return (originalURL.lastPathComponent, thumbnailURL.lastPathComponent)
        } catch {
            print("Ошибка при загрузке изображений: \(error)")
            return (nil, nil)
        }
    }
    
    func resizedImageToSquare(_ image: UIImage, size: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size, height: size)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    //    func resizedImage(_ image: UIImage, width: CGFloat) -> UIImage? {
    //        let aspectRatio = image.size.height / image.size.width
    //        let newHeight = width * aspectRatio
    //        let newSize = CGSize(width: width, height: newHeight)
    //        let renderer = UIGraphicsImageRenderer(size: newSize)
    //        return renderer.image { _ in
    //            image.draw(in: CGRect(origin: .zero, size: newSize))
    //        }
    //    }
    
    private func addProduct() async {
        let (imageUrl, thumbnailUrl) = await uploadPhotos()
        
        guard let imageUrl = imageUrl, let thumbnailUrl = thumbnailUrl else {
            print("Ошибка при загрузке изображений")
            return
        }
        
        guard let selectedManufactureId = selectedManufactureId else {
            print("Ошибка: Не выбран производитель")
            return
        }
        
        guard let selectedProductLineId = selectedProductLineId else {
            print("Ошибка: Не выбрана линейка продуктов")
            return
        }
        
        guard let manufacture = dataManager.manufacturies.first(where: { $0.id == selectedManufactureId }) else {
            print("Ошибка: Производитель не найден")
            return
        }
        
        guard let productLine = dataManager.productLines.first(where: { $0.id == selectedProductLineId }) else {
            print("Ошибка: Линейка продуктов не найдена")
            return
        }
        
        let newItem = Product(
            title: title,
            barcode: barcode,
            descr: description,
            value: value,
            categoryIds: selectedCategories,
            manufactureId: selectedManufactureId,
            manufactureName: manufacture.title,
            productLineId: selectedProductLineId,
            productLineName: productLine.title,
            image: imageUrl,
            thumbnailImage: thumbnailUrl,
            price: price,
            purchasePrice: purchasePrice
        )
        dataManager.addProduct(item: newItem)
    }
}

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
    AddProductView()
}
