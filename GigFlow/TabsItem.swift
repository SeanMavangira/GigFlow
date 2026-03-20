//
//  TabsItem.swift
//  GigFlow
//
//  Created by Sean Mavangira on 20/3/2026.
//

import SwiftUI

struct TabsItem: View {
    var body: some View {
        TabView{
            Dashboard()
                .tabItem{
                    Label("Home", systemImage: "house.fill")
                }
            
            Gigs()
                .tabItem{
                    Label("Gigs", systemImage: "briefcase.fill")
                }
        }
    }
}

#Preview {
    TabsItem()
        .environment(GigData())
}
