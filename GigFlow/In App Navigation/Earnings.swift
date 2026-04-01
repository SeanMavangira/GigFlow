//
//  Earnings.swift
//  GigFlow
//
//  Created by Sean Mavangira on 24/3/2026.
//

import SwiftUI
import Charts

struct Earnings: View {
    @State private var selectedPeriod: EarningsPeriod = .monthly
    @Environment(GigData.self) private var data
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
               
                VStack {
                    Picker("Earnings Period", selection: $selectedPeriod) {
                        ForEach(EarningsPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemGray6))
                
                ScrollView {
                    VStack(spacing: 20) {
                        TotalEarnedCard(selectedPeriod: selectedPeriod)
                        PaymentStatusCard(selectedPeriod: selectedPeriod)
                        RecentTransactionsCard(selectedPeriod: selectedPeriod)
                    }
                    .padding(.top)
                }
            }
        }
    }
}

#Preview {
    Earnings()
        .environment(GigData())
}
