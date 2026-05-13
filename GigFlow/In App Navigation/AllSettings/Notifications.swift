//
//  Notifications.swift
//  GigFlow
//
//  Created by Sean Mavangira on 27/3/2026.
//

import SwiftUI

struct Notifications: View {
    @AppStorage("enableNotifications") var enableNotifications = false
    @AppStorage("deadlineAlerts") var deadlineAlerts = false
    @AppStorage("paymentReminders") var paymentReminders = false
    @AppStorage("enableLiveActivity") var enableLiveActivity = false
    @AppStorage("darkMode") var darkMode = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Global Settings")) {
                    Toggle("Enable All Notifications", isOn: $enableNotifications)
                        .onChange(of: enableNotifications) { _, newValue in
                            if newValue {
                                NotificationManager.shared.requestAuthorization()
                            }
                        }
                }
                
                Section(header: Text("Gig Alerts"), footer: Text("Receive reminders before a project deadline.")) {
                    Toggle("Deadline Reminders", isOn: $deadlineAlerts)
                        .disabled(!enableNotifications)
                    Toggle("Payment Reminders", isOn: $paymentReminders)
                        .disabled(!enableNotifications)
                }
                
                Section(header: Text("Real-time Tracking")) {
                    Toggle("Live Activity (Dynamic Island)", isOn: $enableLiveActivity)
                        .disabled(!enableNotifications)
                }
            }
            .navigationTitle("Notifications")
            .preferredColorScheme(darkMode ? .dark : .light)
        }
    }
}

#Preview {
    Notifications()
}
