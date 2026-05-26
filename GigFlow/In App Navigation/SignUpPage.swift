//
//  SignUpPage.swift
//  GigFlow
//
//  Created by Sean Mavangira on 22/5/2026.
//

import SwiftUI

struct SignUpPage: View {
    @State private var userName = ""
    @State private var password = ""
    @State private var verifyPassword = ""
    @State private var showPassword = false
    @State private var showVerifyPassword = false
    
    @Binding var isLoggedIn: Bool
    
    var isFilled: Bool{
        !userName.isEmpty && !password.isEmpty && !verifyPassword.isEmpty && passwordsMatch
    }
    
    var isPasswordLongEnough: Bool {
        password.count >= 8
    }
    
    var passwordContainsLetter: Bool {
        password.rangeOfCharacter(from: .letters) != nil
    }
    
    var passwordsMatch: Bool {
        password == verifyPassword
    }
    
    var isFormValid: Bool {
        isFilled && isPasswordLongEnough && passwordContainsLetter && passwordsMatch
    }
    var body: some View {
        Image("image1")
            .resizable()
            .frame(width:100, height: 100 )
            .cornerRadius(10)
            .padding()
        
        Text("Sign Up")
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
        
        
        HStack{
            if showPassword{
                TextField("Password", text: $password)
            } else{
                SecureField("Password", text: $password)
            }
            
            Button{
                showPassword.toggle()
            }label: {
                Image(systemName: showPassword ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
            
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding()
        
        
        HStack{
            if showVerifyPassword{
                TextField("Verify Password", text: $verifyPassword)
            }else{
                SecureField("Verify Password", text: $verifyPassword)
            }
            
            Button{
                showVerifyPassword.toggle()
            }label: {
                Image(systemName: showVerifyPassword ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
            
        }
        
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding()
        
        if !password.isEmpty && !isPasswordLongEnough {
            Text("Password must be at least 8 characters long")
                .font(.footnote)
                .foregroundStyle(.red)
        }
        if !password.isEmpty && !passwordContainsLetter {
            Text("Password must contain at least one letter")
                .font(.footnote)
                .foregroundStyle(.red)
        }
        
        if !passwordsMatch && !password.isEmpty && !verifyPassword.isEmpty {
            Text("Passwords don't match")
                .font(.footnote)
                .foregroundStyle(.red)
        }
        
        Button{
            withAnimation {
                    isLoggedIn = true
                }
        }label: {
            ZStack{
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 150, height: 50)
                    .foregroundStyle(isFormValid ? .black : .gray.opacity(0.5))
                Text("Sign In")
                    .foregroundStyle(.white)
                    .bold()
            }
        }
        .disabled(!isFilled)
        .padding(.top, 50)
    }
}

#Preview {
    SignUpPage(isLoggedIn: .constant(false))
}
