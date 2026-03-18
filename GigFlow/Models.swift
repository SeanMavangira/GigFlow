//
//  Models.swift
//  GigFlow
//
//  Created by Sean Mavangira on 18/3/2026.
//



import Foundation
import SwiftUI

import Foundation

struct Gig: Identifiable {
    let id = UUID()
    var title: String
    var clientName: String
    var amount: Double
    var deadline: Date
    var status: GigStatus
    var payType: PayType
    var timeSpentInSeconds: TimeInterval = 0
    var isPaid: Bool = false
    var estimatedEarnings: Double {
        if case .hourly(let rate) = payType {
            return (timeSpentInSeconds / 3600) * rate
        }
        return amount
    }
}

enum GigStatus: String, CaseIterable {
    case active = "Active"
    case pending = "Pending"
    case completed = "Completed"
    case overdue = "Overdue"
}

enum PayType {
    case fixed
    case hourly(rate: Double)
}

struct GigRowView: View {
    
    @Binding var gig: Gig
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                // Now you can toggle the status because it's a Binding!
                if gig.status == .completed {
                    gig.status = .active
                } else {
                    gig.status = .completed
                }
            } label: {
                Image(systemName: gig.status == .completed ? "checkmark.square.fill" : "square")
                    .font(.system(size: 24))
                    .foregroundColor(gig.status == .completed ? .blue : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(gig.title)
                    .font(.system(size: 16, weight: .semibold))
                   
                    .strikethrough(gig.status == .completed)
                    .foregroundColor(gig.status == .completed ? .secondary : .primary)
                
                Text("Due Today • 2h left")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}
