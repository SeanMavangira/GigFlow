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
                Text(incomingText)
                    .font(.largeTitle)
                    .bold()
                    .onAppear {
                        
                        if !hasAppeared {
                            animateText()
                            hasAppeared = true
                        }
                    }
                   
                    NavigationLink{
                        
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
                    
                
                .offset(y: 300)
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
