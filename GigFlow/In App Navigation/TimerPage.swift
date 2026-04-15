//
//  TimerPage.swift
//  GigFlow
//
//  Created by Sean Mavangira on 23/3/2026.
//

import SwiftUI
internal import Combine
import AudioToolbox
import AVFoundation

struct TimerPage: View {
    @Environment(GigData.self) private var data
    
    var hourlyGigs: [Gig] {
        data.gigs.filter {
            if case .hourly = $0.payType { return true }
            return false
        }
    }
    @AppStorage("isTimerSoundEnabled") private var isTimerSoundEnabled = true
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
    @AppStorage("darkMode") var darkMode = false
    @State private var showStatusAlert = false
    
    func playTimerFeedback(isStarting: Bool, isEnabled: Bool) {
        // Check if the user has the sound enabled in your settings page
        guard isEnabled else { return }
        
        
        let soundID: SystemSoundID = isStarting ? 1407 : 1407
        
        AudioServicesPlaySystemSound(soundID)
        
        // Add a haptic "tap" to make it feel premium
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
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
                    .background(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                
                .shadow(radius: 5)
                
                
                .padding(.top, 8)
            }
            .padding(.horizontal)
            .padding(.top, 15)
            
            
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Timer Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white)
                            .frame(width: 380,height: 120)
                            .shadow(radius: 5)
                        
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
                    .shadow(radius: 5)
                    
                    
                    Button {
                        if let gig = data.selectedGig {
                            if isRunning {
                                
                                isRunning = false
                                
                                playTimerFeedback(isStarting: data.isRunning, isEnabled: isTimerSoundEnabled)
                                
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
                                playTimerFeedback(isStarting: true, isEnabled: isTimerSoundEnabled)
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
                    .shadow(radius: 5)
                    
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
                            .foregroundColor(.gray)
                        
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Text(currentEarnings, format: .currency(code: "USD"))
                                    .font(.system(size: 45, weight: .bold))
                                    .foregroundStyle(darkMode ? .white  : .black)
                                
                                if let gig = data.selectedGig, case .hourly(let rate) = gig.payType {
                                    Text("@ \(rate, format: .currency(code: "USD"))/hr")
                                        .font(.subheadline)
                                        .foregroundStyle(darkMode ? .white  : .black)
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16) .fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white))
                    .shadow(radius: 5)
                    
                }
                .padding(20)
                .alert("Gig Not Active", isPresented: $showStatusAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Please make sure the gig status is set to 'Active' in the Gigs page before starting the timer.")
                }
            }
        }
        .preferredColorScheme(darkMode ? .dark : .light)
        
        .onReceive(systemTimer) { _ in
            if isRunning {
                data.timeDone += 1
            }
        }
    }
}



#Preview {
    TimerPage()
        .environment(GigData())
}
