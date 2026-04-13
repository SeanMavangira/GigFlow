//
//  EditName.swift
//  GigFlow
//
//  Created by Sean Mavangira on 9/4/2026.
//

import SwiftUI

struct EditName: View {
    @Binding var name: String
    var body: some View {
        Form{
            Section{
                TextField("Name", text: $name)
            }
        }
        .navigationTitle("Edit Name")
    }
}

#Preview {
    EditName(name:.constant(""))
}
