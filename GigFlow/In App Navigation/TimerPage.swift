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
    @AppStorage("enableLiveActivity") var enableLiveActivity = true
    @AppStorage("isTimerSoundEnabled") private var isTimerSoundEnabled = true
    @AppStorage("darkMode") var darkMode = false
    
    @State private var isRunning = false
    @State private var showStatusAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    let systemTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Computed Properties
    
    var liveSelectedGig: Gig? {
        data.gigs.first(where: { $0.id == data.selectedGig?.id })
    }
    
    var hourlyGigs: [Gig] {
        data.gigs.filter { gig in
            // 1. Must be an hourly gig configuration
            let isHourly = if case .hourly = gig.payType { true } else { false }
            
            // 2. STUCT RULE: Must be explicitly set to active status
            let isActive = gig.status == .active
            
            return isHourly && isActive
        }
    }
    
    var currentEarnings: Double {
        guard let gig = liveSelectedGig else { return 0.0 }
        let totalSeconds = gig.timeSpentInSeconds + Double(data.timeDone)
        
        switch gig.payType {
        case .hourly(let rate):
            return (totalSeconds / 3600.0) * rate
        case .fixed(let amount):
            return amount
        }
    }
    
    // MARK: - Helper Functions
    
    func playTimerFeedback(isStarting: Bool, isEnabled: Bool) {
        guard isEnabled else { return }
        let soundID: SystemSoundID = 1407
        AudioServicesPlaySystemSound(soundID)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    func timeString(from totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gig Selection Menu
            VStack(alignment: .leading, spacing: 12) {
                if hourlyGigs.isEmpty {
                    // Clear message if no eligible hourly gigs are found
                    HStack {
                        Text("No active hourly gigs available")
                            .foregroundColor(.gray)
                            .italic()
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : Color.white)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    .padding(.top, 8)
                } else {
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
                            Text(liveSelectedGig?.title ?? "Choose an hourly gig...")
                                .foregroundColor(liveSelectedGig == nil ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                    .shadow(radius: 5)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal)
            .padding(.top, 15)
            
            ScrollView {
                VStack(spacing: 30) {
                    // --- TIME TRACKING CARD (Width matched to Earnings Card) ---
                    VStack(spacing: 10) {
                        Text("TIME TRACKING")
                            .font(.caption).fontWeight(.bold).foregroundColor(.gray).kerning(1.2)
                        
                        Text(timeString(from: data.timeDone))
                            .font(.system(size: 60, weight: .bold, design: .monospaced))
                    }
                    .frame(maxWidth: .infinity) 
                    .frame(height: 120)
                    .background(RoundedRectangle(cornerRadius: 16).fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white))
                    .shadow(radius: 5)
                    
                    // Action Button
                    Button {
                        if let gig = liveSelectedGig {
                            if isRunning {
                                isRunning = false
                                playTimerFeedback(isStarting: false, isEnabled: isTimerSoundEnabled)
                                var updatedGig = gig
                                updatedGig.timeSpentInSeconds += Double(data.timeDone)
                                data.update(updatedGig)
                                data.timeDone = 0
                                NotificationManager.shared.endLiveActivity()
                            } else {
                                if gig.status == .active {
                                    isRunning = true
                                    playTimerFeedback(isStarting: true, isEnabled: isTimerSoundEnabled)
                                    if enableLiveActivity {
                                        let rate: Double = {
                                            if case .hourly(let r) = gig.payType { return r }
                                            return 0.0
                                        }()
                                        NotificationManager.shared.startLiveActivity(for: gig, rate: rate)
                                    }
                                } else {
                                    alertTitle = "Gig Not Active"
                                    alertMessage = "Please make sure the gig status is set to 'Active' in the Gigs page before starting the timer."
                                    showStatusAlert = true
                                }
                            }
                        } else {
                            alertTitle = "No Gig Selected"
                            alertMessage = "Please select a gig from the menu at the top before starting the timer."
                            showStatusAlert = true
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 140)
                                .foregroundStyle(isRunning ? .red : (liveSelectedGig != nil ? .blue : .gray))
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
                    
                    Button {
                        isRunning = false
                        data.timeDone = 0
                    } label: {
                        Text("Reset Timer")
                            .font(.subheadline).bold().foregroundColor(.gray)
                            .padding(.vertical, 8).padding(.horizontal, 20)
                            .background(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    // --- TOTAL EARNED CARD ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Total Earned")
                            .font(.title2).bold().foregroundColor(.gray)
                        
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Text(currentEarnings, format: .currency(code: "USD"))
                                    .font(.system(size: 45, weight: .bold))
                                    .foregroundStyle(darkMode ? .white : .black)
                                
                                if let gig = liveSelectedGig, case .hourly(let rate) = gig.payType {
                                    Text("Rate: \(rate, format: .currency(code: "USD")) / hour")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity) // Matches the width of the timer card
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white))
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 20) // Parent padding controls both cards equally
                .padding(.vertical, 20)
            }
        }
        .preferredColorScheme(darkMode ? .dark : .light)
        .alert(alertTitle, isPresented: $showStatusAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        // Place this right below your .alert modifier block at the bottom of the file
        .onChange(of: liveSelectedGig?.status) { oldValue, newValue in
            if newValue == .completed {
                isRunning = false
                data.timeDone = 0
                data.selectedGig = nil // Clears the selection slot
                NotificationManager.shared.endLiveActivity()
            }
        }
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

