//
//  AuthManager.swift
//  AromiusGreen
//
//  Created by VictorZima on 18/08/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var isUserAuthenticated: Bool = false
    @Published var currentUser: AppUser?
    
    init() {
        checkUserAuthentication()
    }

    func checkUserAuthentication() {
        if let firebaseUser = Auth.auth().currentUser {
            isUserAuthenticated = true
            fetchUserData(for: firebaseUser)
        } else {
            isUserAuthenticated = false
            currentUser = nil
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isUserAuthenticated = false
            currentUser = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func updateAuthenticationStatus() {
        isUserAuthenticated = true
        if let firebaseUser = Auth.auth().currentUser {
            fetchUserData(for: firebaseUser)
        }
    }
    
    private func fetchUserData(for firebaseUser: FirebaseAuth.User) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(firebaseUser.uid)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let isAdmin = data?["isAdmin"] as? Bool ?? false
                
                self.currentUser = AppUser(
                    id: firebaseUser.uid,
                    firstName: data?["firstName"] as? String ?? "",
                    secondName: data?["secondName"] as? String ?? "",
                    country: data?["country"] as? String ?? "",
                    city: data?["city"] as? String ?? "",
                    email: firebaseUser.email ?? "",
                    photo: data?["photo"] as? String,
                    isAdmin: isAdmin
                )
            } else {
                print("Error fetching user data: \(error?.localizedDescription ?? "No error productDescription")")
                self.currentUser = nil
            }
        }
    }
    
    func saveProfile(firstName: String?, secondName: String?, country: String?, city: String?) {
          guard let currentUser = Auth.auth().currentUser else {
              print("Пользователь не аутентифицирован.")
              return
          }
          
          let userId = currentUser.uid
          let db = Firestore.firestore()
          let userRef = db.collection("users").document(userId)
          
          var updatedData: [String: Any] = [:]
          if let firstName = firstName {
              updatedData["firstName"] = firstName
          }
          if let secondName = secondName {
              updatedData["secondName"] = secondName
          }
          if let country = country {
              updatedData["country"] = country
          }
          if let city = city {
              updatedData["city"] = city
          }
//          if let photo = photo {
//              updatedData["photo"] = photo
//          }
          
          userRef.updateData(updatedData) { error in
              if let error = error {
                  print("Ошибка при обновлении профиля: \(error.localizedDescription)")
//                  DispatchQueue.main.async {
////                      self.errorMessage = error.localizedDescription
////                      self.showingError = true
//                  }
              } else {
                  print("Профиль успешно обновлен")
                  DispatchQueue.main.async {
                      self.currentUser?.firstName = firstName
                      self.currentUser?.secondName = secondName
                      self.currentUser?.country = country
                      self.currentUser?.city = city
//                      self.currentUser?.photo = photo
                  }
              }
          }
      }
    
//    func saveProfile(firstName: String?, secondName: String?, country: String?, city: String?) {
//        guard let currentUser = Auth.auth().currentUser else {
//            print("Пользователь не аутентифицирован.")
//            return
//        }
//        
//        let userId = currentUser.uid
//        let db = Firestore.firestore()
//        let userRef = db.collection("users").document(userId)
//        
//        var updatedData: [String: Any] = [:]
//        if let firstName = firstName, !firstName.isEmpty {
//            updatedData["firstName"] = firstName
//        }
//        if let secondName = secondName, !secondName.isEmpty {
//            updatedData["secondName"] = secondName
//        }
//        if let country = country, !country.isEmpty {
//            updatedData["country"] = country
//        }
//        if let city = city, !city.isEmpty {
//            updatedData["city"] = city
//        }
////        if let photo = photo {
////            updatedData["photo"] = photo
////        }
//        
//        userRef.updateData(updatedData) { error in
//            if let error = error {
//                print("Ошибка при обновлении профиля: \(error.localizedDescription)")
//            } else {
//                print("Профиль успешно обновлен")
//                self.currentUser?.firstName = firstName ?? self.currentUser?.firstName ?? ""
//                self.currentUser?.secondName = secondName ?? self.currentUser?.secondName ?? ""
//                self.currentUser?.country = country ?? self.currentUser?.country ?? ""
//                self.currentUser?.city = city ?? self.currentUser?.city ?? ""
////                self.currentUser?.photo = photo ?? self.currentUser?.photo
//            }
//        }
//    }
    
}
