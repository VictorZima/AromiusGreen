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
    @State private var isShowingAuthView = false

    let columns = Array(repeating: GridItem(.flexible(), spacing: 3, alignment: .leading), count: 1)
    
    var body: some View {
        NavigationView {
            VStack {
                if authManager.isUserAuthenticated {
                    if cartManager.cartItems.isEmpty {
                        Text("Your cart is empty")
                            .font(.title2)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 7) {
                                ForEach(cartManager.cartItems) { item in
                                    CartItemCellView(item: item)
                                }
                            }
                        }
                        
                        HStack {
                            Text("Total:")
                                .font(.headline)
                            Spacer()
                            Text("\(cartManager.totalPrice().formattedPrice()) ₪")
                                .font(.headline)
                        }
                        .padding()
                        
                        NavigationLink {
                            UnderConstructionView()
                        } label: {
                            Text("Proceed to Checkout")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .navigationTitle("Cart")
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
            .navigationTitle("Your Cart")
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
}
