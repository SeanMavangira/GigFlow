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
    @Binding var isLoggedIn: Bool
    
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
                
                Button{
                    withAnimation {
                        isLoggedIn = true 
                    }
                }label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 150, height: 50)
                            .foregroundStyle(isFilled ? .black : .gray.opacity(0.5))
                        Text("Sign In")
                            .foregroundStyle(.white)
                            .bold()
                    }
                }
                .disabled(!isFilled)
                .padding(.top, 50)
                
                NavigationLink{
                    SignUpPage(isLoggedIn: $isLoggedIn)
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
    SignInPage(isLoggedIn: .constant(false) )
        .environment(GigData())
}
