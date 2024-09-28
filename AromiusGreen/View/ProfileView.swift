//
//  ProfileView.swift
//  AromiusGreen
//
//  Created by VictorZima on 18/08/2024.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    @State private var isEditingProfile = false
    @State private var isShowingAuthView = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let user = authManager.currentUser {
                    // Фото пользователя
                    if let photoURL = user.photo, let url = URL(string: photoURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 20)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .padding(.vertical, 20)
                    }
                    
                    // Имя пользователя
                    Text(user.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Страна и город пользователя
                    Text("\(user.city), \(user.country)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        isEditingProfile = true
                    }) {
                        Text("Edit Profile")
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 40)
                    
                    if authManager.currentUser?.isAdmin == true {
                        NavigationLink(destination: AdminView()) {
                            HStack {
                                Image(systemName: "gearshape.2")
                                Text("Manage Store")
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 40)

                    }
                    
                    Spacer()
                    
                    Button(action: signOut) {
                        HStack {
                            Image(systemName: "arrow.backward.circle.fill")
                                .foregroundColor(.white)
                                .imageScale(.medium)
                            Text("Log Out")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                    .navigationTitle("Settings")
                } else {
                    VStack(spacing: 20) {
                        Text("Сохраните свои любимые товары в избранное!")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text("Создайте учетную запись или войдите, чтобы сохранить товары в избранное и легко находить их позже.")
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
            .fullScreenCover(isPresented: $isEditingProfile) {
                EditProfileView(isPresented: $isEditingProfile)
            }
            .sheet(isPresented: $isShowingAuthView) {
                AuthView(isShowingAuthView: $isShowingAuthView)
                    .environmentObject(authManager)
            }
        }
    }
    
    func signOut() {
        authManager.signOut()
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    ProfileView()
}
