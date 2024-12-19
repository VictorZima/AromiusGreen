//
//  DeliveryMethodView.swift
//  AromiusGreen
//
//  Created by VictorZima on 17/10/2024.
//

import SwiftUI

struct DeliveryMethodView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var dataManager: DataManager

    @State private var deliveryMethods: [DeliveryMethod] = []
    @State private var selectedDeliveryMethod: DeliveryMethod? = nil
    @State private var deliveryCost: Double = 0.0
    @State private var isOrderSuccessful = false
    @State private var isShowingOrderAlert = false

    @State private var userAddresses: [Address] = []
    @State private var selectedAddress: Address? = nil

    @State private var isShowingAddAddressView = false

    let pickupMethodId = "OpDyDur05rUy0mqG16WW"

    let storeAddress = Address(
        id: nil,
        firstName: "Магазин",
        lastName: "",
        phone: "000-000-0000",
        country: "Страна",
        city: "Город",
        street: "Улица Магазинная, 1",
        zipCode: "123456",
        isPrimary: false
    )

    var body: some View {
        VStack(alignment: .leading) {
            Text("Выберите способ доставки")
                .font(.headline)
                .padding(.bottom, 10)

            ForEach(deliveryMethods, id: \.id) { method in
                HStack {
                    Button(action: {
                        selectedDeliveryMethod = method
                        selectedAddress = nil
                    }) {
                        HStack {
                            Image(systemName: selectedDeliveryMethod?.id == method.id ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(selectedDeliveryMethod?.id == method.id ? .blue : .gray)
                            VStack(alignment: .leading) {
                                Text(method.title)
                                    .foregroundColor(.black)
                                Text(method.deliveryDescription)
                                    .font(.footnote)
                            }
                            Spacer()
                            Text("₪\(method.cost.formattedPrice())")
                                .font(.system(size: 15))
                                .foregroundColor(Color.black)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 5)
            }

            if let method = selectedDeliveryMethod {
                if method.id == pickupMethodId {
                    Text("Вы выбрали самовывоз. Адрес магазина:")
                        .font(.subheadline)
                        .padding(.top, 10)

                    Text("\(storeAddress.street), \(storeAddress.city), \(storeAddress.zipCode ?? ""), \(storeAddress.country)")
                        .font(.subheadline)
                } else {
                    Text("Выберите адрес доставки")
                        .font(.headline)
                        .padding(.vertical, 10)

                    if userAddresses.isEmpty {
                        Text("У вас нет сохраненных адресов.")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.bottom, 10)

                        Button("Добавить новый адрес") {
                            isShowingAddAddressView = true
                        }
                        .sheet(isPresented: $isShowingAddAddressView, onDismiss: {
                            dataManager.fetchUserAddresses { addresses in
                                userAddresses = addresses
                            }
                        }) {
                            NavigationView {
                                AddEditAddressView()
                                    .environmentObject(dataManager)
                            }
                        }
                    } else {
                        ForEach(userAddresses, id: \.id) { address in
                            HStack {
                                Button(action: {
                                    selectedAddress = address
                                }) {
                                    HStack {
                                        Image(systemName: selectedAddress?.id == address.id ? "largecircle.fill.circle" : "circle")
                                            .foregroundColor(selectedAddress?.id == address.id ? .blue : .gray)
                                        VStack(alignment: .leading) {
                                            Text("\(address.firstName) \(address.lastName)")
                                                .foregroundColor(.black)
                                            Text("\(address.street), \(address.city)")
                                                .font(.footnote)
                                            Text("\(address.zipCode ?? ""), \(address.country)")
                                                .font(.footnote)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 5)
                        }

                        Button("Add new address") {
                            isShowingAddAddressView = true
                        }
                        .sheet(isPresented: $isShowingAddAddressView, onDismiss: {
                            dataManager.fetchUserAddresses { addresses in
                                userAddresses = addresses
                            }
                        }) {
                            NavigationView {
                                AddEditAddressView()
                                    .environmentObject(dataManager)
                            }
                        }
                    }
                }
            }

            Spacer()

            CustomActionButton(title: "Оформить заказ", widthSize: .large, action: {
                placeOrder()
            })
            .disabled(!isOrderReady)
        }
        .padding()
        .onChange(of: selectedDeliveryMethod) { newMethod in
            if let method = newMethod {
                deliveryCost = method.cost
            }
        }
        .onAppear {
            dataManager.fetchDeliveryMethods { methods in
                deliveryMethods = methods
            }
            dataManager.fetchUserAddresses { addresses in
                userAddresses = addresses
            }
        }
        .alert(isPresented: $isShowingOrderAlert) {
            Alert(
                title: Text(isOrderSuccessful ? "Заказ оформлен" : "Ошибка"),
                message: Text(isOrderSuccessful ? "Ваш заказ успешно оформлен." : "Не удалось оформить заказ."),
                dismissButton: .default(Text("OK"), action: {
                    if isOrderSuccessful {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            )
        }
    }

    var isOrderReady: Bool {
        guard let method = selectedDeliveryMethod else { return false }
        if method.id == pickupMethodId {
            return true
        } else {
            return selectedAddress != nil
        }
    }

    func placeOrder() {
        guard let method = selectedDeliveryMethod else { return }

        var deliveryAddress: Address

        if method.id == pickupMethodId {
            deliveryAddress = storeAddress
        } else {
            guard let address = selectedAddress else { return }
            deliveryAddress = address
        }

        dataManager.createOrder(
            cartItems: cartManager.cartItems,
            totalAmount: cartManager.totalPrice(),
            deliveryMethod: method.title,
            deliveryCost: deliveryCost,
            deliveryAddress: deliveryAddress
        ) { success in
            if success {
                isOrderSuccessful = true
                cartManager.clearCart()
                isShowingOrderAlert = true
            } else {
                isOrderSuccessful = false
                isShowingOrderAlert = true
            }
        }
    }
}


//import SwiftUI
//
//struct DeliveryMethodView: View {
//    @EnvironmentObject var cartManager: CartManager
//    @EnvironmentObject var dataManager: DataManager
//    
//    @State private var deliveryMethods: [DeliveryMethod] = []
//    @State private var selectedDeliveryMethod: String? = nil
//    @State private var deliveryCost: Double = 0.0
//    @State private var isOrderSuccessful = false
//    @State private var isShowingOrderAlert = false
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Choose Delivery Method")
//                .font(.headline)
//                .padding(.bottom, 10)
//            
//            ForEach(deliveryMethods, id: \.id) { method in
//                HStack {
//                    Button(action: {
//                        selectedDeliveryMethod = method.id
//                    }) {
//                        HStack {
//                            Image(systemName: selectedDeliveryMethod == method.id ? "largecircle.fill.circle" : "circle")
//                                .foregroundColor(selectedDeliveryMethod == method.id ? .blue : .gray)
//                            VStack(alignment: .leading) {
//                                Text(method.title)
//                                    .foregroundColor(.black)
//                                    
//                                Text(method.deliveryDescription)
//                                    .font(.footnote)
//                            }
//                            
//                            Text("₪")
//                                .font(.system(size: 12))
//                            Text(method.cost.formattedPrice())
//                                .font(.system(size: 15))
//                                .foregroundColor(Color.black)
//                        }
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//                .padding(.vertical, 5)
//            }
//            
//            Spacer()
//            
//            if let selectedMethod = selectedDeliveryMethod {
//                Text("Selected method: \(deliveryMethods.first { $0.id == selectedMethod }?.title ?? "")")
//                    .font(.subheadline)
//                    .padding(.top, 20)
//            }
//            
//            CustomButton(title: "Place order", widthSize: .large, action: {
//                placeOrder()
//            })
//            .disabled(selectedDeliveryMethod == nil)
//        }
//        .padding()
//        .onChange(of: selectedDeliveryMethod) { newMethodId in
//            if let newMethodId = newMethodId,
//               let method = deliveryMethods.first(where: { $0.id == newMethodId }) {
//                deliveryCost = method.cost // Обновляем стоимость доставки при выборе метода
//            }
//        }
//        .onAppear {
//            dataManager.fetchDeliveryMethods { methods in
//                deliveryMethods = methods
//            }
//        }
//        .alert(isPresented: $isShowingOrderAlert) {
//            Alert(
//                title: Text(isOrderSuccessful ? "Order Successful" : "Order Failed"),
//                message: Text(isOrderSuccessful ? "Your order has been placed successfully." : "Failed to place the order."),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//    }
//    
//    func placeOrder() {
//        guard let selectedMethod = selectedDeliveryMethod else { return }
//        
//        dataManager.createOrder(cartItems: cartManager.cartItems, totalAmount: cartManager.totalPrice(), deliveryMethod: selectedMethod, deliveryCost: deliveryCost) { success in
//            if success {
//                isOrderSuccessful = true
//                cartManager.clearCart()
//                isShowingOrderAlert = true
//            } else {
//                isOrderSuccessful = false
//                isShowingOrderAlert = false
//            }
//        }
//    }
//}

#Preview {
    DeliveryMethodView()
}
