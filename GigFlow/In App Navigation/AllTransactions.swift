//
//  AllTransactions.swift
//  GigFlow
//
//  Created by Sean Mavangira on 26/5/2026.
//

import SwiftUI

struct AllTransactions: View {
    @AppStorage("darkMode") var darkMode = false
    @Environment(GigData.self) private var data
    
    var allGroupedTransactions: [(month: String, gigs: [Gig])] {
        let dictionary = Dictionary(grouping: data.gigs) { $0.deadline.monthYearString }
        return dictionary.map { (month: $0.key, gigs: $0.value.sorted(by: { $0.deadline > $1.deadline })) }
            .sorted { left, right in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return (formatter.date(from: left.month) ?? Date.distantPast) > (formatter.date(from: right.month) ?? Date.distantPast)
            }
    }
    
    var body: some View {
       
            ScrollView {
                VStack(alignment: .leading, spacing: 22) { // Distance between month blocks
                    
                    ForEach(allGroupedTransactions, id: \.month) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            
                            // 1. Month Header Label
                            Text(group.month)
                                .font(.title3)
                                .bold()
                                .foregroundStyle(darkMode ? .white : .black)
                                .padding(.leading, 4)
                            
                            // 2. The Single Rectangle Master Card Container
                            VStack(spacing: 0) {
                                ForEach(group.gigs) { gig in
                                    DetailedTransactionRow(gig: gig)
                                    
                                    // Inserts a clean separator line under every item EXCEPT the last one
                                    if gig.id != group.gigs.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .padding(.horizontal, 16) // Padding inside the card container edges
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white)
                            )
                            .shadow( radius: 5)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("All Transactions")
        
    }
}



#Preview {
    AllTransactions()
        .environment(GigData())
}
