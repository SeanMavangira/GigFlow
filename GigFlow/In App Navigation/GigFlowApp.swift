//
//  GigFlowApp.swift
//  GigFlow
//
//  Created by Sean Mavangira on 18/3/2026.
//

import SwiftUI

@main
struct GigFlowApp: App {
    @State private var data = GigData()
    
    init() {
            NotificationManager.shared.requestAuthorization()
        }
    
    var body: some Scene {
        WindowGroup {
           TabsItem()
                .environment(data)
        }
    }
}
