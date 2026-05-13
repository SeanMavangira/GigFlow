//
//  GigFlowWidgetLiveActivity.swift
//  GigFlowWidget
//
//  Created by Sean Mavangira on 4/5/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GigFlowWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        // This links the Widget to the 'GigAttributes' you created in your NotificationManager
        ActivityConfiguration(for: GigAttributes.self) { context in
            // --- LOCK SCREEN UI (The banner on the lock screen) ---
            VStack {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.blue)
                    Text(context.attributes.gigName)
                        .font(.headline)
                    Spacer()
                    // This creates the live counting timer
                    Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                        .monospacedDigit()
                        .bold()
                }
            }
            .padding()
            
        } dynamicIsland: { context in
            DynamicIsland {
                // --- EXPANDED VIEW (When you long-press the Dynamic Island) ---
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.gigName, systemImage: "briefcase")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                        .monospacedDigit()
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Tracking Gig Time")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                // --- COMPACT LEFT (The little bubble) ---
                Image(systemName: "timer")
                    .foregroundColor(.blue)
            } compactTrailing: {
                // --- COMPACT RIGHT (The little bubble) ---
                Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                    .monospacedDigit()
                    .frame(width: 45)
            } minimal: {
                // --- MINIMAL (When multiple islands are active) ---
                Image(systemName: "timer")
                    .foregroundColor(.blue)
            }
        }
    }
}

