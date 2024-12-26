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
                    Text("profile")
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
                    
                    let location = makeLocation(country: user.country, city: user.city)
                    Text(location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    
                    CustomActionButton(title: "edit_profile", widthSize: .medium)  {
                        isEditingProfile = true
                    }
                    
                    HStack(alignment: .center, spacing: 5) {
                        if authManager.currentUser?.isAdmin == true {
                            NavigationLink {
                                AdminHomeView()
                            } label: {
                                VStack {
                                    Image(systemName: "storefront")
                                        .foregroundStyle(Color.darkBlueItem)
                                        .font(.title2)
                                    Text("my_store_button")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.darkBlueItem)
                                }
                                .frame(width: 90, height: 70)
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
                                Text("orders_button")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.darkBlueItem)
                            }
                            .frame(width: 70, height: 70)
                        }
                        Divider()
                            .frame(width: 1, height: 60)
                            .background(Color.lightBlue)
                        
                        NavigationLink {
                            SettingsView()
                        } label: {
                            VStack {
                                Image(systemName: "gearshape.2")
                                    .foregroundStyle(Color.darkBlueItem)
                                    .font(.title2)
                                Text("settings_button")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.darkBlueItem)
                            }
                            .frame(width: 70, height: 70)
                        }
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                    
                    Button(action: signOut) {
                        HStack {
                            Image(systemName: "arrow.backward.circle.fill")
                                .foregroundColor(.white)
                                .imageScale(.medium)
                            Text("logout")
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
                        Text("create_login_description")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        CustomActionButton(title: "signin_register_button", widthSize: .large) {
                            isShowingAuthView = true
                        }
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
    
    private func makeLocation(country: String?, city: String?) -> String {
        if let city = city, let country = country {
            return "\(country), \(city)"
        } else {
            return country ?? city ?? ""
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
