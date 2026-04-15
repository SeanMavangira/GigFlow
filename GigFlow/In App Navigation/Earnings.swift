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
    @AppStorage("darkMode") var darkMode = false
    var body: some View {
        ZStack {

            
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
                .shadow(radius: 5)
                
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
        .preferredColorScheme(darkMode ? .dark : .light)
    }
}

#Preview {
    Earnings()
        .environment(GigData())
}
