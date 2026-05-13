//
//  Timer.swift
//  GigFlow
//
//  Created by Sean Mavangira on 27/3/2026.
//

import SwiftUI
import AVFoundation

struct TimerSettingPage: View {
    @AppStorage("isTimerSoundEnabled") private var isTimerSoundEnabled = false
    
    func triggerTimerFeedback(isStarting: Bool) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let soundID: SystemSoundID = isStarting ? 1104 : 1054
        AudioServicesPlaySystemSound(soundID)
    }
    var body: some View {
        Form{
            Toggle("Timer Sound", isOn: $isTimerSoundEnabled)
        }
        .navigationTitle("Timer Settings")
    }
}

#Preview {
    TimerSettingPage()
}
