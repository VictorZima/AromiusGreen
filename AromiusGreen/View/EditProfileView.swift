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
    @State private var photo: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Имя", text: $firstName)
                TextField("Фамилия", text: $secondName)
                TextField("Страна", text: $country)
                TextField("Город", text: $city)
                // Здесь также может быть UI для загрузки/выбора фото
            }
            .navigationBarTitle("Редактировать профиль", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Отмена") {
                    isPresented = false
                },
                trailing: Button("Сохранить") {
                    saveProfileChanges()
                    isPresented = false
                }
            )
        }
        .onAppear {
            if let user = authManager.currentUser {
                firstName = user.firstName
                secondName = user.secondName
                country = user.country
                city = user.city
                photo = user.photo ?? ""
            }
        }
    }
    
    func saveProfileChanges() {
        authManager.saveProfile(
            firstName: firstName,
            secondName: secondName,
            country: country,
            city: city,
            photo: photo
        )
    }
}


#Preview {
    EditProfileView(isPresented: .constant(true))
        .environmentObject(AuthManager())
}
