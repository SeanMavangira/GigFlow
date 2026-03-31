//
//  TabsItem.swift
//  GigFlow
//
//  Created by Sean Mavangira on 20/3/2026.
//

import SwiftUI

struct TabsItem: View {
    @Environment(GigData.self) private var data
    @State var selectedTab: Tabs = .dashboard
    
    var body: some View {
       
        TabView(selection: $selectedTab) {
            
            
            NavigationStack {
                Dashboard()
                    .navigationTitle(Tabs.dashboard.rawValue)
                   
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(Tabs.dashboard)
            
            
            NavigationStack {
                Gigs()
                    .navigationTitle(Tabs.gigs.rawValue)
            }
            .tabItem {
                Label("Gigs", systemImage: "briefcase.fill")
            }
            .tag(Tabs.gigs)
            
           
            NavigationStack {
                TimerPage()
                    .navigationTitle(Tabs.timer.rawValue)
            }
            .tabItem {
                Label("Timer", systemImage: "clock.fill")
            }
            .tag(Tabs.timer)
            
            
            NavigationStack {
                Earnings()
                    .navigationTitle(Tabs.earnings.rawValue)
            }
            .tabItem {
                Label("Earnings", systemImage: "dollarsign.circle.fill")
            }
            .tag(Tabs.earnings)
        }
    }
}

#Preview {
    TabsItem()
        .environment(GigData())
}
