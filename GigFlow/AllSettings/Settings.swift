//
//  Settings.swift
//  GigFlow
//
//  Created by Sean Mavangira on 27/3/2026.
//

import SwiftUI

struct Settings: View {
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    NavigationLink(destination: AccountAndProfile()) {
                        Label("Account & Profile", systemImage: "person.circle")
                    }
                    
                    NavigationLink(destination: Currency()){
                        Label("Currency", systemImage: "dollarsign.circle")
                    }
                    
                    NavigationLink(destination: Notifications()){
                        Label("Notifications", systemImage: "bell.circle")
                    }
                    
                    NavigationLink(destination: TimerSettingPage()){
                        Label("Timer Settings", systemImage: "clock.circle")
                    }
                    
                    NavigationLink(destination: Appearance()){
                        Label("Appearance", systemImage: "moon.circle")
                    }
                }
            }
        }
    }
}

#Preview {
    Settings()
}
