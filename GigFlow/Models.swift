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
    var status: GigPicker
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
    case all = "All"
    case active = "Active"
    case pending = "Pending"
    case completed = "Completed"
}

enum GigPicker: String, CaseIterable, Identifiable {
    case draft = "Draft"
    case active = "Active"
    case pending = "Pending"
    case completed = "Completed"
    
    var id: String { self.rawValue }
}

enum PayType {
    case fixed
    case hourly(rate: Double)
    
    
    var isFixed: Bool {
        if case .fixed = self { return true }
        return false
    }
}

struct GigRowView: View {
    
    @Binding var gig: Gig
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                
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

@Observable
class GigData {
    var gigs: [Gig] = [
        Gig(title: "Edit Video for John", clientName: "John Doe", amount: 500, deadline: Date(), status: .draft, payType: .fixed),
        Gig(title: "Write Blog Post", clientName: "Sarah J.", amount: 7, deadline: Date(), status: .pending, payType: .hourly(rate: 30)),
        Gig(title: "Consultation", clientName: "Mike R.", amount: 100, deadline: Date(), status: .active, payType: .fixed),
        Gig(title: "Thumbnail Design", clientName: "Vlog Channel", amount: 50, deadline: Date(), status: .completed, payType: .fixed)
    ]
    
    func update(_ updatedGig: Gig) {
        if let index = gigs.firstIndex(where: { $0.id == updatedGig.id }) {
            gigs[index] = updatedGig
        }
    }
    
    func deleteGig(_ gig: Gig) {
        gigs.removeAll { $0.id == gig.id }
    }
    
        var isRunning: Bool = false
        var timeDone: Int = 0
        var selectedGig: Gig?
}

struct GigCard: View {
    let gig: Gig
    var onEdit: () -> Void
    
    @Environment(GigData.self) private var data
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(width: 380, height: 150)
                .shadow(radius: 5)
            
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(gig.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    Menu {
                        Button {
                            onEdit()
                        } label: {
                            Label("Edit Gig", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            withAnimation(.spring()) {
                                
                                data.deleteGig(gig)
                            }
                        } label: {
                            Label("Delete Gig", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .padding(5)
                            .contentShape(Rectangle())
                    }
                    
                }
                
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Deadline: ")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(gig.deadline, format: .dateTime.month().day())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Button {
                       
                        withAnimation(.spring()) {
                            toggleStatus()
                        }
                    } label: {
                      
                        Text(gig.status.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(statusColor.opacity(0.15))
                            .foregroundColor(statusColor)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                
                
                HStack {
                    Text("Client: \(gig.clientName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    
                    HStack(spacing: 2) {
                        
                        Text(gig.amount, format: .currency(code: "USD"))
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(gig.payType.isFixed ? " (Fixed)" : "/hr")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .frame(width: 380, height: 150, alignment: .topLeading)
        }
    }
    
    // Helper to get colors based on your Enum
    var statusColor: Color {
        switch gig.status {
        case .active: return .blue
        case .pending: return .orange
        case .completed: return .green
        default: return .gray
        }
    }
    
    func toggleStatus() {
        var updatedGig = gig
        
        switch gig.status {
        case .draft:     updatedGig.status = .active
        case .active:    updatedGig.status = .pending
        case .pending:   updatedGig.status = .completed
        case .completed: updatedGig.status = .draft
        }
        
        data.update(updatedGig)
    }
}

func timeString(from totalSeconds: Int) -> String {
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}


enum Tabs: String, CaseIterable{
    case dashboard = "Dashboard"
    case gigs = "Gigs"
    case timer = "Timer"
    case earnings = "Earnings"
}

