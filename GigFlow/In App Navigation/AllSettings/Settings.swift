//
//  Settings.swift
//  GigFlow
//
//  Created by Sean Mavangira on 27/3/2026.
//

import SwiftUI

struct Settings: View {
    @AppStorage("darkMode") var darkMode = false
    var body: some View {
        
        Form{
            Section{
                NavigationLink(destination: AccountAndProfile()) {
                    Label("Account & Profile", systemImage: "person.circle")
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
        .preferredColorScheme(darkMode ? .dark : .light)
        
    }
}

#Preview {
    Settings()
}
