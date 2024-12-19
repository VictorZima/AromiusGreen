//
//  EditProfileView.swift
//  AromiusGreen
//
//  Created by VictorZima on 26/08/2024.
//

import SwiftUI
struct EditProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isPresented: Bool
    
    @State private var firstName: String = ""
    @State private var secondName: String = ""
    @State private var country: String = ""
    @State private var city: String = ""

    var body: some View {
        HStack {
            Button("Cancel") {
                isPresented = false
            }
            Spacer()
            Button("Save") {
                saveProfileChanges()
                isPresented = false
            }
        }
        .padding()
        
        Form {
            Section(header: Text("Личные данные")) {
                customTextField("Имя", text: $firstName)
                customTextField("Фамилия", text: $secondName)
                customTextField("Страна", text: $country)
                customTextField("Город", text: $city)
            }
        }
        .formStyle(.columns)
        .navigationBarTitle("Редактировать профиль", displayMode: .inline)
        Spacer()

        .onAppear {
            loadUserProfile()
        }
    }
    
    @ViewBuilder
    func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(Color.clear)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
    }
    
    func loadUserProfile() {
        if let user = authManager.currentUser {
            firstName = user.firstName ?? ""
            secondName = user.secondName ?? ""
            country = user.country ?? ""
            city = user.city ?? ""
        }
    }
    
    func saveProfileChanges() {
        authManager.saveProfile(
            firstName: firstName,
            secondName: secondName,
            country: country,
            city: city
        )
    }
}


#Preview {
    EditProfileView(isPresented: .constant(true))
        .environmentObject(AuthManager())
}
