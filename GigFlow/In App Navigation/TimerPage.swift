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
    
    let systemTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
 
    
    var liveSelectedGig: Gig? {
        data.gigs.first(where: { $0.id == data.selectedGig?.id })
    }
    
    var hourlyGigs: [Gig] {
        data.gigs.filter {
            if case .hourly = $0.payType { return true }
            return false
        }
    }
    
    /// CALCULATED AMOUNT: Shows exactly what has been earned based on time spent
    var currentEarnings: Double {
        guard let gig = liveSelectedGig else { return 0.0 }
        
        // We calculate based on the total time (saved time + current session time)
        let totalSeconds = gig.timeSpentInSeconds + Double(data.timeDone)
        
        switch gig.payType {
        case .hourly(let rate):
            // (Seconds / 3600) gives the fraction of the hour, multiplied by rate
            return (totalSeconds / 3600.0) * rate
        case .fixed(let amount):
            return amount
        }
    }
    
    
    
    func playTimerFeedback(isStarting: Bool, isEnabled: Bool) {
        guard isEnabled else { return }
        let soundID: SystemSoundID = 1407
        AudioServicesPlaySystemSound(soundID)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gig Selection Menu
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
            .padding(.horizontal)
            .padding(.top, 15)
            
            ScrollView {
                VStack(spacing: 30) {
                    // Timer Display
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white)
                            .frame(height: 120)
                            .shadow(radius: 5)
                        
                        VStack(spacing: 10) {
                            Text("TIME TRACKING")
                                .font(.caption).fontWeight(.bold).foregroundColor(.gray).kerning(1.2)
                            
                            Text(timeString(from: data.timeDone))
                                .font(.system(size: 60, weight: .bold, design: .monospaced))
                        }
                    }
                    .padding(.horizontal)
                    
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
                                    showStatusAlert = true
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 140)
                                .foregroundStyle(isRunning ? .red : (liveSelectedGig?.status == .active ? .blue : .gray))
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
                    .disabled(liveSelectedGig == nil)
                    .opacity(liveSelectedGig == nil ? 0.5 : 1.0)
                    
                    Button {
                        isRunning = false
                        data.timeDone = 0
                    } label: {
                        Text("Reset Timer")
                            .font(.subheadline).bold().foregroundColor(.gray)
                            .padding(.vertical, 8).padding(.horizontal, 20)
                            .background(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    // FIXED EARNINGS CARD: Shows actual calculated amount
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Total Earned")
                            .font(.title2).bold().foregroundColor(.gray)
                        
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                // This shows the actual dollar amount calculated from the time
                                Text(currentEarnings, format: .currency(code: "USD"))
                                    .font(.system(size: 45, weight: .bold))
                                    .foregroundStyle(darkMode ? .white : .black)
                                
                                // This shows the static rate for reference
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
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white))
                    .shadow(radius: 5)
                }
                .padding(20)
            }
        }
        .preferredColorScheme(darkMode ? .dark : .light)
        .alert("Gig Not Active", isPresented: $showStatusAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please make sure the gig status is set to 'Active' in the Gigs page before starting the timer.")
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

