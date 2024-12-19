//
//  AddEditAddressView.swift
//  AromiusGreen
//
//  Created by VictorZima on 10/10/2024.
//

import SwiftUI

struct AddEditAddressView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var country = ""
    @State private var city = ""
    @State private var street = ""
    @State private var zipCode = ""
    @State private var isPrimary = false

    var address: Address?
    
    var body: some View {
        Form {
            Section(header: Text("Contact Details")) {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                TextField("Phone", text: $phone)
            }

            Section(header: Text("Address Details")) {
                TextField("Street", text: $street)
                TextField("City", text: $city)
                TextField("Zip Code", text: $zipCode)
                TextField("Country", text: $country)
                Toggle("Set as Primary", isOn: $isPrimary)
            }
        }
        .navigationTitle(address == nil ? "Add Address" : "Edit Address")
        .navigationBarItems(trailing: Button("Save") {
            saveAddress()
        }.disabled(!isFormValid))
        .onAppear {
            if let address = address {
                // Заполняем поля при редактировании
                firstName = address.firstName
                lastName = address.lastName
                phone = address.phone
                country = address.country
                city = address.city
                street = address.street
                zipCode = address.zipCode ?? ""
                isPrimary = address.isPrimary
            }
        }
    }

    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !phone.isEmpty &&
        !country.isEmpty &&
        !city.isEmpty &&
        !street.isEmpty
    }

    func saveAddress() {
        let newAddress = Address(
            id: address?.id, // Сохраняем существующий id при редактировании
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            country: country,
            city: city,
            street: street,
            zipCode: zipCode.isEmpty ? nil : zipCode,
            isPrimary: isPrimary
        )

        if isPrimary {
            dataManager.resetPrimaryAddress { success in
                if success {
                    saveOrUpdateAddress(newAddress)
                } else {
                    // Обработка ошибки
                }
            }
        } else {
            saveOrUpdateAddress(newAddress)
        }
    }

    func saveOrUpdateAddress(_ newAddress: Address) {
        if address == nil {
            // Добавление нового адреса
            dataManager.addAddress(newAddress) { success in
                if success {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    print("Не удалось добавить адрес")
                }
            }
        } else {
            // Обновление существующего адреса
            dataManager.updateAddress(newAddress) { success in
                if success {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    print("Не удалось обновить адрес")
                }
            }
        }
    }
}

    
#Preview {
    AddEditAddressView(address: nil)
}
