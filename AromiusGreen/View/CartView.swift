//
//  CartView.swift
//  AromiusGreen
//
//  Created by VictorZima on 20/09/2024.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var dataManager: DataManager
    
    @State private var isShowingAuthView = false
    @State private var selectedDeliveryMethod = "Self-pickup"
    @State private var deliveryCost: Double = 0.0
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 3, alignment: .leading), count: 1)
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Cart")
                        .foregroundColor(.darkBlueItem)
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                .padding(16)
                
                if authManager.isUserAuthenticated {
                    if cartManager.cartItems.isEmpty {
                        VStack {
                            Text("Your cart is empty")
                                .font(.title2)
                                .padding()                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 7) {
                                ForEach(cartManager.cartItems) { item in
                                    CartItemCellView(item: item)
                                }
                            }
                            
                            VStack {
//                                HStack {
//                                    Text("Delivery")
//                                    Spacer()
//                                    Picker("Delivery Method", selection: $selectedDeliveryMethod) {
//                                        ForEach(deliveryMethods, id: \.self) {
//                                            Text($0)
//                                        }
//                                    }
//                                    .pickerStyle(MenuPickerStyle())
//                                    .onChange(of: selectedDeliveryMethod) { method in
//                                        if method == "Paid delivery" {
//                                            deliveryCost = 30.0
//                                        } else {
//                                            deliveryCost = 0.0
//                                        }
//                                    }
//                                }
//                                .padding(.bottom)
//                                Spacer()
//                                
//                                HStack {
//                                    Text("Total without delivery:")
//                                        .font(.headline)
//                                    Spacer()
//                                    Text("\(cartManager.totalPrice().formattedPrice()) ₪")
//                                        .font(.headline)
//                                }
//                                
//                                HStack {
//                                    Text("Delivery Cost:")
//                                        .font(.headline)
//                                    Spacer()
//                                    Text("\(deliveryCost, specifier: "%.2f") ₪")
//                                        .font(.headline)
//                                }
//                                
//                                HStack {
//                                    Text("Total with delivery:")
//                                        .font(.headline)
//                                    Spacer()
//                                    Text("\((cartManager.totalPrice() + deliveryCost).formattedPrice()) ₪")
//                                        .font(.headline)
//                                }
                                
                                CustomButton(title: "Оформить заказ", widthSize: .large, destination: {
                                    
                                    AnyView(DeliveryMethodView())
                                }
                                )
                                    .padding(.horizontal)
                                    .padding(.bottom, 6)
                            }
                            .padding()
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Text("Your cart is empty!")
                            .font(.title2)
                            .padding()
                        Text("Please sign in or register to save items to your cart and view them later.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button {
                            isShowingAuthView = true
                        } label: {
                            Text("Sign in or Register")
                                .foregroundColor(.green)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 17)
                                        .stroke(Color.green, lineWidth: 2)
                                )
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .sheet(isPresented: $isShowingAuthView) {
                AuthView(isShowingAuthView: $isShowingAuthView)
                    .environmentObject(authManager)
            }
        }
    }
}

#Preview {
    CartView()
        .environmentObject(CartManager())
        .environmentObject(AuthManager())
        .environmentObject(DataManager())
}
