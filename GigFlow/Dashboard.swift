//
//  ContentView.swift
//  GigFlow
//
//  Created by Sean Mavangira on 18/3/2026.
//

import  SwiftUI
struct Dashboard: View {
    @Environment(GigData.self) private var data
    
    // Helper to get gigs due exactly today
    var todayGigs: [Binding<Gig>] {
        @Bindable var bindableData = data
        return $bindableData.gigs.filter { $gig in
            Calendar.current.isDateInToday($gig.deadline.wrappedValue)
        }
    }

    // Helper to get gigs due exactly tomorrow
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
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    
                    // Earnings Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.white)
                            .frame(height: 130)
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Earnings:")
                                .font(.title)
                                .bold()
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            HStack {
                                Spacer()
                                // Sums up all gig amounts in the array
                                Text("$\(String(format: "%.2f", data.gigs.reduce(0) { $0 + $1.amount }))")
                                    .font(.system(size: 40, weight: .bold))
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    // Today's Tasks Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.white)
                            .frame(height: 300)
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Today's Tasks")
                                    .font(.headline)
                                    .bold()
                                Spacer()
                            }
                            .padding()
                            
                            Divider()
                            
                            ScrollView {
                                VStack(spacing: 0) {
                                    // Uses bindable data to pass bindings to rows
                                    ForEach(todayGigs) { $gig in
                                        GigRowView(gig: $gig)
                                            .padding(.horizontal)
                                        Divider().padding(.horizontal)
                                    }
                                }
                            }
                            .frame(height: 235)
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .clipped()
                    }
                    
                    // Upcoming Deadlines Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.white)
                            .frame(height: 300)
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Upcoming Deadlines")
                                    .bold()
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
                    }
                    
                    HStack {
                        // Active Gigs Card
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 170, height: 150)
                                .foregroundStyle(.white)
                                .shadow(radius: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(alignment: .topLeading) {
                                    Text("Active Gigs")
                                        .bold()
                                        .font(.title2)
                                        .padding()
                                }
                                .overlay(alignment: .center) {
                                    HStack {
                                        // Dynamic count of gigs
                                        Text("\(data.gigs.count)")
                                            .offset(y: 20)
                                            .bold()
                                            .font(.largeTitle)
                                        Button {} label: {
                                            Text("In Progress >")
                                                .offset(y: 20)
                                                .font(.headline)
                                                .foregroundStyle(.black)
                                        }
                                    }
                                    .padding()
                                }
                        }
                        
                        Spacer()
                        
                        // Pending Payments
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 170, height: 150)
                                .foregroundStyle(.white)
                                .shadow(radius: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .overlay(alignment: .topLeading) {
                                    Text("Pending Payments")
                                        .bold()
                                        .font(.title2)
                                        .padding()
                                }
                                .overlay(alignment: .center) {
                                    HStack {
                                        Text("\(data.gigs.count)")
                                            .offset(y: 20)
                                            .font(.largeTitle)
                                            .bold()
                                        
                                        Button {} label: {
                                            Text("Pending >")
                                                .font(.headline)
                                                .foregroundStyle(.black)
                                        }
                                        .offset(y: 20)
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let previewData = GigData()
    return Dashboard()
            .environment(previewData)
}
