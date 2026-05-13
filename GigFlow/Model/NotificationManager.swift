//
//  NotificationManager.swift
//  GigFlow
//
//  Created by Sean Mavangira on 4/5/2026.
//


import Foundation
import UserNotifications
import ActivityKit

@Observable
class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications Authorized")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    // Schedule a reminder for a Gig Deadline
    func scheduleDeadlineReminder(for gig: Gig) {
        let content = UNMutableNotificationContent()
        content.title = "Project Deadline Approaching! ⚠️"
        content.body = "Your gig '\(gig.title)' is due soon."
        content.sound = .default

        // Trigger 2 hours before the deadline
        let triggerDate = gig.deadline.addingTimeInterval(-7200) 
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: gig.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    func startLiveActivity(for gig: Gig, rate: Double) {
        // 1. Check if authorized
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        // 2. Setup the static data (Name of gig)
        let attributes = GigAttributes(gigName: gig.title)
        
        // 3. Setup the dynamic data (The rate and start time)
        // We use .now so the Dynamic Island can count UP automatically
        let initialState = GigAttributes.ContentState(hourlyRate: rate, startTime: .now)
        
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            // 4. Ask iOS to start the Dynamic Island session
            let _ = try Activity.request(attributes: attributes, content: content)
            print("Dynamic Island Started")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func endLiveActivity() {
            Task {
                // This loops through all active "Gig" activities and stops them
                for activity in Activity<GigAttributes>.activities {
                    await activity.end(dismissalPolicy: .immediate)
                }
                print("Live Activity ended")
            }
        }
}
struct GigAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var hourlyRate: Double
        var startTime: Date
    }
    var gigName: String
}
