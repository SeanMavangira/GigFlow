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
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    TabsItem()
                } else {
                    WelcomePage(isLoggedIn: $isLoggedIn)
                }
            }
            .environment(data)
        }
    }
}
