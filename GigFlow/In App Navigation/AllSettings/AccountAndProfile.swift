//
//  AccountAndProfile.swift
//  GigFlow
//
//  Created by Sean Mavangira on 27/3/2026.
//

import SwiftUI
import PhotosUI

struct AccountAndProfile: View {
    @AppStorage("email") var email: String = ""
    @AppStorage("currency") var currency: String = ""
    @AppStorage("name") var name = ""
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
    
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        
        Form {
            
            Section {
                VStack {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            Group {
                                if let profileImage {
                                    profileImage
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundStyle(.gray.opacity(0.3))
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            
                            Image(systemName: "plus.circle.fill")
                                .symbolRenderingMode(.multicolor)
                                .font(.system(size: 30))
                                .background(Color.white.clipShape(Circle()))
                                .offset(x: 4, y: 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            
            Section {
                NavigationLink(destination:EditName(name: $name)) {
                    HStack {
                        Text("Name:")
                        Text(name).foregroundStyle(.secondary)
                    }
                }
                
                NavigationLink(destination: EditEmail(email: $email)) {
                    HStack {
                        Text("Email:")
                        Text(email).foregroundStyle(.secondary)
                    }
                }
                
                NavigationLink(destination: EditCurrency(selectedCurrency: $currency)) {
                    HStack {
                        Text("Default Currency:")
                        Text(currency).foregroundStyle(.secondary)
                    }
                }
            }
            
            
            Section {
                Button(role: .destructive) {
                    showLogoutConfirmation = true
                } label: {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                }
            }
        }
        .navigationTitle("Account & Profile")
        .navigationBarTitleDisplayMode(.inline)
        
  
        .alert("Logout", isPresented: $showLogoutConfirmation) {
                        Button("Yes", role: .destructive) {
                           
                           
                        }
                        Button("No", role: .cancel) {
                           
                        }
                    } message: {
                        Text("Do you want to log out?")
                    }
        
       
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        profileImage = Image(uiImage: uiImage)
                                    }
                                }
                            }
    
    }
}


#Preview {
    AccountAndProfile()
}
