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
    @AppStorage("darkMode") var darkMode = false
    
    // Permanent storage for the photo as Data
    @AppStorage("profileImageData") private var profileImageData: Data?
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var showLogoutConfirmation = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    // Computed property to turn stored Data back into a viewable Image
    var profileImage: Image {
        if let data = profileImageData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "person.circle.fill")
        }
    }
    
    var body: some View {
        Form {
            // Profile Picture Section
            Section {
                VStack {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .foregroundStyle(.gray.opacity(0.3)) // Only applies to placeholder
                            
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
            
            // Info Section
            Section {
                NavigationLink(destination: EditName(name: $name)) {
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
            
            // Actions Section
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
        .preferredColorScheme(darkMode ? .dark : .light)
        
        // Logout Alert
        .alert("Logout", isPresented: $showLogoutConfirmation) {
            Button("Yes", role: .destructive) {
                withAnimation(.easeInOut) {
                    isLoggedIn = false
                }
            }
            Button("No", role: .cancel) { }
        } message: {
            Text("Do you want to log out?")
        }
        
        // Photo Picker Logic
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    // This line saves the photo permanently to AppStorage
                    profileImageData = data
                }
            }
        }
    }
}


#Preview {
    AccountAndProfile()
}
