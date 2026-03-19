//
//  ContentView.swift
//  GigFlow
//
//  Created by Sean Mavangira on 18/3/2026.
//

import  SwiftUI
struct Dashboard: View {
    @State private var earnings = 2150.00
    @State var activeGigs = 6
    
    @State var sampleGigs = [
        Gig(title: "Edit Video for John", clientName: "John Doe", amount: 500, deadline: Date(), status: .active, payType: .fixed),
        Gig(title: "Write Blog Post", clientName: "Sarah J.", amount: 0, deadline: Date(), status: .pending, payType: .hourly(rate: 30)),
        Gig(title: "Consultation", clientName: "Mike R.", amount: 100, deadline: Date(), status: .active, payType: .fixed),
        Gig(title: "Thumbnail Design", clientName: "Vlog Channel", amount: 50, deadline: Date(), status: .active, payType: .fixed)
    ]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    
                    //  Earnings Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.white)
                            .frame(height: 130)
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Earnings:")
                                .font(.title)
                                .bold()
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            HStack {
                                Spacer()
                                Text("$\(String(format: "%.2f", earnings))")
                                    .font(.system(size: 40, weight: .bold))
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    // Today's Tasks Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.white)
                            .frame(height: 300)
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Today's Tasks")
                                    .font(.headline)
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            
                            Divider()
                            
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach($sampleGigs) { $gig in
                                        GigRowView(gig: $gig)
                                            .padding(.horizontal)
                                        Divider().padding(.horizontal)
                                    }
                                }
                            }
                            .frame(height: 235)
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .clipped()
                    }
                    
                    // Upcoming Dealines card
                    ZStack{
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.white)
                            .frame(height: 300)
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        VStack(alignment: .leading, spacing: 0){
                            HStack{
                                Text("Upcoming Dealines")
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            
                            Divider()
                            
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach($sampleGigs) { $gig in
                                        GigRowView(gig: $gig)
                                            .padding(.horizontal)
                                        Divider().padding(.horizontal)
                                    }
                                }
                            }
                            .frame(height: 235)
                        }
                    }
                    
                   
                    HStack{
                        // Active Gigs Card
                        ZStack{
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 170, height: 150)
                                .foregroundStyle(.white)
                                .shadow(radius: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            
                                .overlay(alignment: .topLeading){
                                    Text("Active Gigs")
                                        .bold()
                                        .font(.title2)
                                        .padding()
                                    
                                }
                            
                                .overlay(alignment: .center){
                                    HStack{
                                        Text("\(activeGigs)")
                                            .offset(y: 20)
                                            .bold()
                                            .font(.largeTitle)
                                        Button{
                                            
                                        }label: {
                                            Text("In Progress >")
                                                .offset(y: 20)
                                                .font(.headline)
                                                .foregroundStyle(.black)
                                        }
                                    }
                                    .padding()
                                }
                        }
                        
                        Spacer()
                        
                        // Pending Payments
                        ZStack{
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 170, height: 150)
                                .foregroundStyle(.white)
                                .shadow(radius: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            
                                .overlay(alignment: .topLeading){
                                    Text("Pending Payments")
                                        .bold()
                                        .font(.title2)
                                        .padding()
                                }
                            
                                .overlay(alignment: .center){
                                    HStack{
                                        Text("\(activeGigs)")
                                            .offset(y: 20)
                                            .font(.largeTitle)
                                            .bold()
                                        
                                        Button{
                                            
                                        }label: {
                                            Text("Pending >")
                                                .font(.headline)
                                                .foregroundStyle(.black)
                                        }
                                        .offset(y: 20)
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    Dashboard()
}
