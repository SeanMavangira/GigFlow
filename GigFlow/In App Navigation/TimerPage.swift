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
        
        
        let totalSeconds = gig.timeSpentInSeconds + Double(data.timeDone)
        
        switch gig.payType {
        case .hourly(let rate):
            return (totalSeconds / 3600.0) * rate
        case .fixed(let amount):
            return amount
        }
    }
    
    @State private var showStatusAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            
            VStack(alignment: .leading, spacing: 12) {
                
                
                Menu {
                    ForEach(hourlyGigs) { gig in
                        Button {
                            self.data.selectedGig = gig
                        } label: {
                            if case .hourly(let rate) = gig.payType {
                                Text("\(gig.title) ($\(Int(rate))/hr)")
                            } else {
                                Text(gig.title)
                            }
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
                
                
                .padding(.top, 8)
            }
            .padding(.horizontal)
            .padding(.top, 15)
            .background(Color(UIColor.systemGray6))
            
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Timer Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 380,height: 120)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        VStack(spacing: 10) {
                            Text("TIME TRACKING")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .kerning(1.2)
                            
                            Text(timeString(from: data.timeDone))
                                .font(.system(size: 60, weight: .bold, design: .monospaced))
                        }
                    }
                    
                    
                    Button {
                        if let gig = data.selectedGig {
                            if isRunning {
                               
                                isRunning = false
                                var updatedGig = gig
                                updatedGig.timeSpentInSeconds += Double(data.timeDone)
                                data.update(updatedGig)
                                data.timeDone = 0
                            } else {
                               
                                if gig.status == .active {
                                    isRunning = true
                                } else {
                                    
                                    showStatusAlert = true
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 140)
                                .foregroundStyle(isRunning ? .red : (data.selectedGig?.status == .active ? .blue : .gray))
                                .shadow(radius: 4)
                            
                            VStack(spacing: 4) {
                                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                    .font(.system(size: 35))
                                Text(isRunning ? "Stop" : "Start")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                        }
                    }
                   
                    .opacity(data.selectedGig == nil ? 0.5 : 1.0)
                        
                       
                        Button {
                            isRunning = false
                            data.timeDone = 0
                        } label: {
                            Text("Reset Timer")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.gray)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        }
                        
                        // Earnings Card
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Earnings")
                                .font(.title2)
                                .bold()
                            
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Text(currentEarnings, format: .currency(code: "USD"))
                                        .font(.system(size: 45, weight: .bold))
                                        .foregroundStyle(.black)
                                    
                                    if let gig = data.selectedGig, case .hourly(let rate) = gig.payType {
                                        Text("@ \(rate, format: .currency(code: "USD"))/hr")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                    }
                    .padding(20)
                    .alert("Gig Not Active", isPresented: $showStatusAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Please make sure the gig status is set to 'Active' in the Gigs page before starting the timer.")
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .background(Color(UIColor.systemGray6).ignoresSafeArea())
            .onReceive(systemTimer) { _ in
                if isRunning {
                    data.timeDone += 1
                }
            }
            //        .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    

#Preview {
    TimerPage()
        .environment(GigData())
}
