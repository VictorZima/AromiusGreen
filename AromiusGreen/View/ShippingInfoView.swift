//
//  ShippingInfoView.swift
//  AromiusGreen
//
//  Created by VictorZima on 10/10/2024.
//

import SwiftUI

struct ShippingInfoView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var addresses: [Address] = []
    @State private var showDeleteConfirmation = false
    @State private var addressToDelete: Address?
    @State private var isShowingAddEditAddressView = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
           
            VStack {
                if addresses.isEmpty {
                    Spacer()
                    Text("You have no saved addresses.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List(addresses) { address in
                        HStack {
                            Button {
                                addressToDelete = address
                                showDeleteConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            NavigationLink(destination: AddEditAddressView(address: address)) {
                                AddressRow(address: address)
                            }
                        }
                    }
                    .listStyle(.grouped)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    
                    NavigationLink {
                        AddEditAddressView(address: nil)
                    } label: {
                        Text("Add new address")
                            .foregroundColor(.darkBlueItem)
                            .frame(width: 200)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.darkBlueItem, lineWidth: 1)
                            )
                    }
                    .padding(.bottom)
                }
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Удалить адрес?"),
                        message: Text("Вы уверены, что хотите удалить этот адрес?"),
                        primaryButton: .destructive(Text("Удалить")) {
                            if let addressToDelete = addressToDelete {
                                deleteAddress(address: addressToDelete)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
        .onAppear {
            loadAddresses()
        }
    }
    
    func loadAddresses() {
        dataManager.fetchUserAddresses { fetchedAddresses in
            self.addresses = fetchedAddresses
        }
    }
    
    func deleteAddress(address: Address) {
        dataManager.deleteAddress(address) { success in
            if success {
                loadAddresses()
            }
        }
    }
}

#Preview {
    ShippingInfoView()
        .environmentObject(DataManager())
}
