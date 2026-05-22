//
//  SignInPage.swift
//  GigFlow
//
//  Created by Sean Mavangira on 20/5/2026.
//

import SwiftUI

struct SignInPage: View {
    @State private var userName = ""
    @State private var password = ""
    
    var isFilled: Bool{
        !userName.isEmpty && !password.isEmpty
    }
    var body: some View {
        VStack{
            NavigationStack{
                Image("image1")
                    .resizable()
                    .frame(width:100, height: 100 )
                    .cornerRadius(10)
                    .padding()
                Text("Sign In")
                    .bold()
                    .font(.largeTitle)
                    .padding(.top, 40)
                
                TextField("User Name", text: $userName)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .padding()
                
                TextField("Password", text: $password)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .padding()
                
                if !isFilled {
                    Text("Please fill in all text fields to sign in.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
                NavigationLink{
                    TabsItem()
                        .navigationBarBackButtonHidden()
                }label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 150, height: 50)
                            .foregroundStyle(.black)
                        Text("Sign In")
                            .foregroundStyle(.white)
                            .bold()
                    }
                }
                .disabled(!isFilled)
                .padding(.top, 50)
                
                NavigationLink{
                    
                }label: {
                    HStack{
                        Text("Dont have an account?")
                        
                            .foregroundStyle(.gray)
                        Text("Sign Up")
                            .foregroundStyle(.blue)
                    }
                }
                
                .padding(.top, 30)
            }
        }
        
    }
}

#Preview {
    SignInPage()
        .environment(GigData())
}
