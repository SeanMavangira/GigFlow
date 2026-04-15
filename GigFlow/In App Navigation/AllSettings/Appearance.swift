//
//  Appearance.swift
//  GigFlow
//
//  Created by Sean Mavangira on 27/3/2026.
//

import SwiftUI

struct Appearance: View {
    @AppStorage("darkMode") var darkMode = false
    var body: some View {
        Form{
            Toggle("Dark Mode", isOn: $darkMode)
        }
        .navigationTitle("Appearance")
        .preferredColorScheme(darkMode ? .dark : .light)
    }
}

#Preview {
    Appearance()
}
