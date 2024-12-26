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
            Button("cancel_nav_bar") {
                isPresented = false
            }
            Spacer()
            Button("save_nav_bar") {
                saveProfileChanges()
                isPresented = false
            }
        }
        .padding()

        Form {
            Section(header: Text("personal_info").padding(.leading, 16).padding(.bottom, 8)) {
                customTextField("first_name_textfield", text: $firstName)
                customTextField("last_name_textfield", text: $secondName)
                customTextField("country_textfield", text: $country)
                customTextField("city_textfield", text: $city)
            }
        }
        .formStyle(.columns)
        Spacer()

        .onAppear {
            loadUserProfile()
        }
//        .navigationBarTitle("edit_profile", displayMode: .inline)
    }
    
    @ViewBuilder
    func customTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(LocalizedStringKey(placeholder), text: text)
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
