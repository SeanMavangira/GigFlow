//
//  WelcomePage.swift
//  GigFlow
//
//  Created by Sean Mavangira on 18/5/2026.
//

import SwiftUI

struct WelcomePage: View {
    
    @State private var incomingText = ""
    private let fullText = "Welcome To GigFlow"
    @State private var hasAppeared = false
    
    var body: some View {
        NavigationStack{
            VStack{
                Image("image1")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .cornerRadius(50)
                    .padding()
                Text(incomingText)
                    .padding(.top, 30)
                    .font(.largeTitle)
                    .bold()
                    .onAppear {
                        
                        if !hasAppeared {
                            animateText()
                            hasAppeared = true
                        }
                    }
                   
                    NavigationLink{
                       SignInPage()
                            .navigationBarBackButtonHidden()
                    }label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 150, height: 50)
                                .foregroundStyle(.black)
                            Text("Next")
                                .foregroundStyle(.white)
                                .bold()
                        }
                    }
                .offset(y: 100)
            }
        }
        
    }
    
    func animateText() {
        for (index, character) in fullText.enumerated() {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                incomingText.append(character)
            }
        }
    }
}


#Preview {
    WelcomePage()
        .environment(GigData())
    
}
