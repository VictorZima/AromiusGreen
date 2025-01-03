//
//  AuthView.swift
//  AromiusGreen
//
//  Created by VictorZima on 19/08/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isRegistration = false
    @Binding var isShowingAuthView: Bool
    
    var body: some View {
        VStack {
            Text(isRegistration ? "create_account" : "log_in")
                .font(.largeTitle)
                .padding(.bottom, 20)
            TextField("email_textfield", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .keyboardType(.emailAddress)

            SecureField("password_textfield", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            if isRegistration {
                SecureField("password_confirm_textfield", text: $confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            CustomActionButton(title: "\(isRegistration ? "sign_up" : "log_in")", widthSize: .large, action: isRegistration ? register : login)
            .padding(.top, 20)
            
            Spacer()
            
            Button(action: {
                isRegistration.toggle()
            }) {
                Text(isRegistration ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
        }
        .padding()
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Both fields are required."
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = nil
                authManager.updateAuthenticationStatus()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func register() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let userData = authResult?.user {
                errorMessage = nil
                saveUserToFirestore(userData)
                authManager.updateAuthenticationStatus()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func saveUserToFirestore(_ user: FirebaseAuth.User) {
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData([
            "email": user.email ?? "",
            "createdAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error adding user to Firestore: \(error.localizedDescription)")
            } else {
                print("User added to Firestore successfully")
            }
        }
    }
}

#Preview {
    AuthView(isShowingAuthView: .constant(false))
        .environmentObject(AuthManager())
}
