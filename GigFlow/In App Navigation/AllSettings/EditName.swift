//
//  EditName.swift
//  GigFlow
//
//  Created by Sean Mavangira on 9/4/2026.
//

import SwiftUI

struct EditName: View {
    @Binding var name: String
    @AppStorage("darkMode") var darkMode = false
    var body: some View {
        Form{
            Section{
                TextField("Name", text: $name)
            }
        }
        .navigationTitle("Edit Name")
        .preferredColorScheme(darkMode ? .dark : .light)
    }
}

#Preview {
    EditName(name:.constant(""))
}
