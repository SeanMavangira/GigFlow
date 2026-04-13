//
//  EditEmail.swift
//  GigFlow
//
//  Created by Sean Mavangira on 9/4/2026.
//

import SwiftUI

struct EditEmail: View {
    @Binding var email: String
    var body: some View {
        Form{
            Section{
                TextField("Email", text: $email)
            }
        }
        .navigationTitle("Edit Email")
    }
}

#Preview {
    EditEmail(email: .constant(""))
}
