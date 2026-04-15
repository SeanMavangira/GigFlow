//
//  EditEmail.swift
//  GigFlow
//
//  Created by Sean Mavangira on 9/4/2026.
//

import SwiftUI

struct EditEmail: View {
    @Binding var email: String
    @AppStorage("darkMode") var darkMode = false
    var body: some View {
        Form{
            Section{
                TextField("Email", text: $email)
            }
        }
        .navigationTitle("Edit Email")
        .preferredColorScheme(darkMode ? .dark : .light)
    }
}

#Preview {
    EditEmail(email: .constant(""))
}
