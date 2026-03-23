//
//  TimerPage.swift
//  GigFlow
//
//  Created by Sean Mavangira on 23/3/2026.
//

import SwiftUI

struct TimerPage: View {
    @Environment(GigData.self) private var data
    
    // Filtered list for hourly gigs only
    var hourlyGigs: [Gig] {
        data.gigs.filter {
            if case .hourly = $0.payType { return true }
            return false
        }
    }
    
    @State private var selectedGig: Gig?
    @State private var timeDone = 0
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 40) {
                
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Gig")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.secondary)
                    
                    Menu {
                        ForEach(hourlyGigs) { gig in
                            Button {
                                self.selectedGig = gig
                            } label: {
                                Text("\(gig.title) ($\(Int(gig.amount))/hr)")
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedGig?.title ?? "Choose an hourly gig...")
                                .foregroundColor(selectedGig == nil ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                
                Spacer()
                
              
                VStack(spacing: 10) {
                    Text("Time Tracking")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .kerning(1.5)
                    
                    Text(timeString(from: timeDone))
                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity)
                }
                
                Spacer()
                
            }
            .padding(25)
            .onAppear {
               
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    timeDone += 1
                }
            }
        }
    }
}

#Preview {
    TimerPage()
        .environment(GigData())
}
