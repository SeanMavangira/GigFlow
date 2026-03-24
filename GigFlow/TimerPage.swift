//
//  TimerPage.swift
//  GigFlow
//
//  Created by Sean Mavangira on 23/3/2026.
//

import SwiftUI
internal import Combine

struct TimerPage: View {
    @Environment(GigData.self) private var data
    
   
    var hourlyGigs: [Gig] {
        data.gigs.filter {
            if case .hourly = $0.payType { return true }
            return false
        }
    }
    @State private var isRunning = false
   

    let systemTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var currentEarnings: Double {
        guard let gig = data.selectedGig else { return 0.0 }
        
        if case .hourly(let rate) = gig.payType {
            
            return (Double(data.timeDone) / 3600.0) * rate
        }
        
        return 0.0
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            ScrollView{
                VStack(spacing: 40) {
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Gig")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(.black)
                        
                        Menu {
                            ForEach(hourlyGigs) { gig in
                                Button {
                                    self.data.selectedGig = gig
                                } label: {
                                    Text("\(gig.title) ($\(Int(gig.amount))/hr)")
                                    
                                }
                            }
                        } label: {
                            HStack {
                                Text(data.selectedGig?.title ?? "Choose an hourly gig...")
                                    .foregroundColor(data.selectedGig == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    
                    Spacer()
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 16)
                            .frame(height: 120)
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                        VStack(spacing: 10) {
                            Text("Time Tracking")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .kerning(1.5)
                            
                            Text(timeString(from: data.timeDone))
                                .font(.system(size: 60, weight: .bold, design: .monospaced))
                                .frame(maxWidth: .infinity)
                        }
                        
                    }
                    
                    Button{
                        isRunning.toggle()
                        
                        if !isRunning, var gig = data.selectedGig {
                            gig.timeSpentInSeconds += Double(data.timeDone)
                                data.update(gig)
                            }
                    }label:{
                        ZStack{
                            Circle()
                                .frame(width: 150)
                                .foregroundStyle(isRunning ? .red.opacity(0.8) : .gray.opacity(0.3))
                                .shadow(radius: 5)
                            VStack(spacing: 8) {
                                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(isRunning ? .white : .black)
                                
                                Text(isRunning ? "Stop" : "Start")
                                    .font(.headline)
                                    .foregroundColor(isRunning ? .white : .black)
                            }
                            
                        }
                    }
                    .disabled(data.selectedGig == nil)
                    
                    Button{
                        isRunning = false
                        data.timeDone = 0
                    }label:{
                        ZStack{
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 100, height: 50)
                                .foregroundStyle(.gray)
                            Text("Reset")
                                .foregroundStyle(.white)
                                .bold()
                        }
                    }
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.white)
                        .shadow(radius: 5)
                        .frame(width: 380, height: 200)
                        .overlay(alignment: .topLeading){
                            Text("Earnings")
                                .bold()
                                .font(.title)
                                .padding()
                        }
                        .overlay {
                            VStack(spacing: 4) {
                                Text(currentEarnings, format: .currency(code: "USD"))
                                    .font(.largeTitle)
                                    .foregroundStyle(.green)
                                    .bold()
                                
                                if let gig = data.selectedGig {
                                    if case .hourly(let rate) = gig.payType {
                                        Text("@ \(rate, format: .currency(code: "USD"))/hr")
                                            .font(.headline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Text("No gig selected")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    
                    //                Spacer()
                }
                .padding(25)
                .onReceive(systemTimer) { _ in
                                    if isRunning {
                                        data.timeDone += 1
                                    }
                                }
            }
        }
    }
}

#Preview {
    TimerPage()
        .environment(GigData())
}
