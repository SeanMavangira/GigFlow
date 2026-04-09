//
//  ContentView.swift
//  GigFlow
//
//  Created by Sean Mavangira on 18/3/2026.
//

import  SwiftUI
struct Dashboard: View {
    @Environment(GigData.self) private var data
    
    var todayGigs: [Binding<Gig>] {
        @Bindable var bindableData = data
        return $bindableData.gigs.filter { $gig in
            Calendar.current.isDateInToday($gig.deadline.wrappedValue)
        }
    }
    
    var upcomingGigs: [Binding<Gig>] {
        @Bindable var bindableData = data
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: .now) ?? .now)
        
        return $bindableData.gigs.filter { $gig in
            $gig.deadline.wrappedValue >= tomorrow
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 25) {
                    
                    // Earnings Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                            .frame(height: 130)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                        
                        VStack(alignment: .leading) {
                            Text("Earnings:")
                                .font(.title)
                                .bold()
                            
                            Spacer()
                            
                            HStack {
                                Spacer()
                                Text("$\(String(format: "%.2f", data.gigs.filter { $0.status == .completed }.reduce(0) { $0 + $1.amount }))")
                                    .font(.system(size: 40, weight: .bold))
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    // Today's Tasks Card
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Today's Tasks")
                                .font(.headline).bold()
                            Spacer()
                        }
                        .padding()
                        
                        Divider()
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(todayGigs) { $gig in
                                    GigRowView(gig: $gig)
                                        .padding(.horizontal)
                                    Divider().padding(.horizontal)
                                }
                            }
                        }
                        .frame(height: 235)
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    
                    // Upcoming Deadlines Card
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Upcoming Deadlines").bold()
                            Spacer()
                        }
                        .padding()
                        
                        Divider()
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(upcomingGigs) { $gig in
                                    GigRowView(gig: $gig)
                                        .padding(.horizontal)
                                    Divider().padding(.horizontal)
                                }
                            }
                        }
                        .frame(height: 235)
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    
                    // Stats Row
                    HStack(spacing: 15) {
                        StatBox(title: "Active Gigs", value: "\(data.gigs.filter { $0.status == .active }.count)")
                        StatBox(title: "Pending", value: "\(data.gigs.filter { $0.status == .pending }.count)")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 20)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: Settings()) {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}





#Preview {
    let previewData = GigData()
    return Dashboard()
        .environment(previewData)
}

