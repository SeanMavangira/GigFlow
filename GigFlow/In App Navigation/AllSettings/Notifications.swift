//
//  Notifications.swift
//  GigFlow
//
//  Created by Sean Mavangira on 27/3/2026.
//

import SwiftUI

struct Notifications: View {
    @AppStorage("darkMode") var darkMode = false
    var body: some View {
        Form{
            
        }
            .preferredColorScheme(darkMode ? .dark : .light)
    }
}

#Preview {
    Notifications()
}
