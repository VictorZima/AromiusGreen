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
            VStack(alignment: .center) {
                HStack {
                    Text("Profile")
                        .foregroundColor(.darkBlueItem)
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                .padding(16)
                
                if let user = authManager.currentUser {
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
                    
                    Text(user.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(user.city), \(user.country)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button {
                        isEditingProfile = true
                    } label: {
                        Text("Edit Profile")
                            .foregroundColor(Color.darkBlueItem)
                            .padding()
                            .background(Color.clear)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.darkBlueItem, lineWidth: 1)
                            )
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 40)
                    
                    HStack(alignment: .center, spacing: 5) {
                        if authManager.currentUser?.isAdmin == true {
                            NavigationLink {
                                AdminView()
                            } label: {
                                VStack {
                                    Image(systemName: "storefront")
                                        .foregroundStyle(Color.darkBlueItem)
                                        .font(.title2)
                                    Text("My Store")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.darkBlueItem)
                                }
                                .frame(width: 70, height: 70)
                            }
                            Divider()
                                .frame(width: 1, height: 60)
                                .background(Color.lightBlue)
                        }
                        
                        NavigationLink {
                            OrdersView()
                        } label: {
                            VStack {
                                Image(systemName: "shippingbox")
                                    .foregroundStyle(Color.darkBlueItem)
                                    .font(.title2)
                                Text("Orders")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.darkBlueItem)
                            }
                            .frame(width: 70, height: 70)
                        }
                        Divider()
                            .frame(width: 1, height: 60)
                            .background(Color.lightBlue)
                    }
                    .padding(.horizontal, 20)
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
                } else {
                    VStack(spacing: 20) {
                        
                        Text("Create an account or log in to enjoy all the benefits: add products to your cart and favorites, receive notifications about special offers and discounts, and more!.")
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
        .environmentObject(AuthManager())
}
