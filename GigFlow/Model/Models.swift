//
//  Models.swift
//  GigFlow
//
//  Created by Sean Mavangira on 18/3/2026.
//



import Foundation
import SwiftUI
import Charts
struct Gig: Identifiable, Codable {
    var id = UUID()
    var title: String
    var clientName: String
    var deadline: Date
    var status: GigPicker
    var payType: PayType
    var timeSpentInSeconds: TimeInterval = 0
    var isPaid: Bool = false
    
    var amount: Double {
        switch payType {
        case .hourly(let rate):
            return (timeSpentInSeconds / 3600.0) * rate
        case .fixed(let fixedAmount):
            return fixedAmount
        }
    }
}

enum GigStatus: String, CaseIterable, Codable {
    case all = "All"
    case active = "Active"
    case pending = "Pending"
    case completed = "Completed"
}

enum GigPicker: String, CaseIterable, Identifiable, Codable {
    case draft = "Draft"
    case active = "Active"
    case pending = "Pending"
    case completed = "Completed"
    
    var id: String { self.rawValue }
}

enum PayType: Codable, Equatable {
    case fixed(amount: Double)
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
                
                Text("\(relativeDate(for: gig.deadline))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
    func relativeDate(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Due Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Due Tomorrow"
        } else {
            // Calculates the number of days between now and the deadline
            let components = calendar.dateComponents([.day], from: .now, to: date)
            let days = components.day ?? 0
            
            if days < 0 {
                return "\(abs(days)) days overdue"
            } else {
                return "Due in \(days) days"
            }
        }
    }
}

@Observable
class GigData {
    var gigs: [Gig] {
        didSet {
            save()
        }
    }
    
    var isRunning: Bool = false {
        didSet { UserDefaults.standard.set(isRunning, forKey: "isRunning") }
    }
    
    var timeDone: Int = 0 {
        didSet { UserDefaults.standard.set(timeDone, forKey: "timeDone") }
    }
    
    var selectedGig: Gig?

    init() {
        // Load Gigs
        if let data = UserDefaults.standard.data(forKey: "saved_gigs"),
           let decoded = try? JSONDecoder().decode([Gig].self, from: data) {
            self.gigs = decoded
        } else {
            self.gigs = []
        }
        
        // Load State
        self.isRunning = UserDefaults.standard.bool(forKey: "isRunning")
        self.timeDone = UserDefaults.standard.integer(forKey: "timeDone")
    }
    
    func addGig(_ gig: Gig) {
        gigs.append(gig)
    }
    
    func update(_ updatedGig: Gig) {
        if let index = gigs.firstIndex(where: { $0.id == updatedGig.id }) {
            gigs[index] = updatedGig
        }
    }
    
    func deleteGig(_ gig: Gig) {
        gigs.removeAll { $0.id == gig.id }
        if selectedGig?.id == gig.id {
            selectedGig = nil
            isRunning = false
            timeDone = 0
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(gigs) {
            UserDefaults.standard.set(encoded, forKey: "saved_gigs")
        }
    }
}

struct GigCard: View {
    let gig: Gig
    let liveSeconds: Double
    var onEdit: () -> Void
    
    @Environment(GigData.self) private var data
    @AppStorage("darkMode") var darkMode = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white)
                .frame(height: 150) // Removed fixed width for better responsiveness
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
                        Button { onEdit() } label: {
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
                            .font(.caption)
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
                    
                    // --- LIVE CALCULATION LOGIC ---
                    VStack(alignment: .trailing, spacing: 0) {
                        switch gig.payType {
                        case .hourly(let rate):
                            // Calculate dollars based on the liveSeconds passed from the parent
                            let earned = (liveSeconds / 3600.0) * rate
                            Text(earned, format: .currency(code: "USD"))
                                .font(.headline)
                                .fontWeight(.bold)
                                .contentTransition(.numericText()) // Smoothly animates numbers
                            
                            Text("$\(Int(rate))/hr")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                        case .fixed(let amount):
                            Text(amount, format: .currency(code: "USD"))
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Fixed")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(20)
        }
        .padding(.horizontal)
    }
    
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

enum EarningsPeriod: String, CaseIterable {
    case monthly = "This Month"
    case yearly = "This Year"
}

extension Date {
    var isInCurrentMonth: Bool {
        let calendar = Calendar.current
        let now = Date()
        return calendar.component(.year, from: self) == calendar.component(.year, from: now)
        && calendar.component(.month, from: self) == calendar.component(.month, from: now)
    }
    
    var isInCurrentYear: Bool {
        let calendar = Calendar.current
        let now = Date()
        return calendar.component(.year, from: self) == calendar.component(.year, from: now)
    }
}

struct PieSegment: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let color: Color
}

struct TotalEarnedCard: View {
    let selectedPeriod: EarningsPeriod
    @Environment(GigData.self) private var data
    @AppStorage("darkMode") var darkMode = false
    
    // Sum of ALL completed gigs up to now
    var paidTotal: Double {
        data.gigs.filter { gig in
            let matchesPeriod = selectedPeriod == .monthly ? gig.deadline.isInCurrentMonth : gig.deadline.isInCurrentYear
            return matchesPeriod && gig.status == .completed
        }.reduce(0.0) { $0 + $1.amount }
    }
    
    var pendingTotal: Double {
        data.gigs.filter { gig in
            let matchesPeriod = selectedPeriod == .monthly ? gig.deadline.isInCurrentMonth : gig.deadline.isInCurrentYear
            return matchesPeriod && (gig.status == .pending || gig.status == .active)
        }.reduce(0.0) { $0 + $1.amount }
    }
    
    var chartData: [(label: String, amount: Double, date: Date)] {
        let calendar = Calendar.current
        
        let filteredGigs = data.gigs.filter { gig in
            if selectedPeriod == .monthly {
                return gig.deadline.isInCurrentMonth && gig.status == .completed
            } else {
                return gig.deadline.isInCurrentYear && gig.status == .completed
            }
        }
        
        let grouped = Dictionary(grouping: filteredGigs) { (gig: Gig) -> String in
            if selectedPeriod == .monthly {
                return "Week \(calendar.component(.weekOfMonth, from: gig.deadline))"
            } else {
                return gig.deadline.formatted(.dateTime.month(.abbreviated))
            }
        }
        
        return grouped.map { (key: String, value: [Gig]) in
            let representativeDate = value.first?.deadline ?? Date()
            return (label: key, amount: value.reduce(0.0) { $0 + $1.amount }, date: representativeDate)
        }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Earned")
                .font(.headline)
                .foregroundStyle(darkMode ? .white : .black)
            
            Text(paidTotal, format: .currency(code: "USD"))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(paidTotal > 0 ? (darkMode ? .white : .black) : .black)
            
            HStack(spacing: 15) {
                Label("Paid: \(paidTotal, format: .currency(code: "USD"))", systemImage: "circle.fill")
                    .foregroundStyle(paidTotal > 0 ? .green : .black)
                Label("Pending: \(pendingTotal, format: .currency(code: "USD"))", systemImage: "circle.fill")
                    .foregroundStyle(pendingTotal > 0 ? .orange : .black)
            }
            .font(.caption.bold())
            
            // --- UPDATED CHART AREA WITH DEMO VIEW ---
            ZStack {
                if chartData.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.gray.opacity(0.3))
                        
                        Text("No completed gigs for this \(selectedPeriod == .monthly ? "month" : "year")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .italic()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Chart {
                        ForEach(chartData, id: \.label) { dataPoint in
                            BarMark(
                                x: .value("Time", dataPoint.label),
                                y: .value("Amount", dataPoint.amount)
                            )
                            .foregroundStyle(
                                darkMode ? Color(red: 0.1, green: 0.4, blue: 0.1).gradient : Color.green.gradient
                            )
                            .cornerRadius(4)
                        }
                    }
                }
            }
            .frame(height: 150)
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white)
        )
        .padding(.horizontal)
        .shadow(radius: 5)
    }
}

struct PaymentStatusCard: View {
    let selectedPeriod: EarningsPeriod
    @Environment(GigData.self) private var data
    @AppStorage("darkMode") var darkMode = false
    
    var body: some View {
        // Calculate totals
        let paid = data.gigs.filter {
            (selectedPeriod == .monthly ? $0.deadline.isInCurrentMonth : $0.deadline.isInCurrentYear) && $0.status == .completed
        }.reduce(0.0) { $0 + $1.amount }
        
        let pending = data.gigs.filter {
            (selectedPeriod == .monthly ? $0.deadline.isInCurrentMonth : $0.deadline.isInCurrentYear) && ($0.status == .pending || $0.status == .active)
        }.reduce(0.0) { $0 + $1.amount }
        
        let total = paid + pending
        
        let pieData = [
            PieSegment(
                category: "Paid",
                amount: paid,
                color: darkMode ? Color(red: 0.1, green: 0.4, blue: 0.1) : .green
            ),
            PieSegment(
                category: "Pending",
                amount: pending,
                color: darkMode ? Color(red: 0.6, green: 0.3, blue: 0.0) : .orange
            )
        ]
        
        VStack(alignment: .leading, spacing: 20) {
            Text("Payment Status")
                .font(.headline)
            
            HStack(spacing: 30) {
                // --- CHART / PLACEHOLDER IMAGE ---
                ZStack {
                    if total == 0 {
                        // Empty State: A light ring with an icon in the center
                        
                        Circle()
                            .stroke(lineWidth: 12)
                            .foregroundStyle(.gray.opacity(0.1))
                        
                        Image(systemName: "creditcard.and.123")
                            .font(.title)
                            .foregroundStyle(.gray.opacity(0.4))
                    } else {
                        // Live State: The Donut Chart
                        Chart(pieData) { segment in
                            SectorMark(
                                angle: .value("Amount", segment.amount),
                                innerRadius: .ratio(0.65),
                                angularInset: 2
                            )
                            .foregroundStyle(segment.color)
                            .cornerRadius(5)
                        }
                    }
                }
                .frame(width: 120, height: 120)
                
                // LEGEND
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(pieData) { segment in
                        HStack {
                            Circle()
                                .fill(total == 0 ? .gray.opacity(0.2) : segment.color)
                                .frame(width: 8, height: 8)
                            
                            Text(segment.category)
                                .font(.caption)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Text(segment.amount, format: .currency(code: "USD"))
                                .font(.caption.bold())
                                .monospacedDigit()
                                .foregroundStyle(total == 0 ? .black : (darkMode ? .white : .black))
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white)
        )
        .padding(.horizontal)
        .shadow(radius: 5)
    }
}

struct RecentTransactionsCard: View {
    let selectedPeriod: EarningsPeriod
    @AppStorage("darkMode") var darkMode = false
    @Environment(GigData.self) private var data
    
    var recentTransactions: [Gig] {
        data.gigs.filter { gig in
            let matchesPeriod = selectedPeriod == .monthly ? gig.deadline.isInCurrentMonth : gig.deadline.isInCurrentYear
            let isValidStatus = gig.status == .completed || gig.status == .pending /*|| gig.status == .active*/
            return matchesPeriod && isValidStatus
        }.sorted(by: { $0.deadline > $1.deadline })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Transactions").font(.headline)
            
            if recentTransactions.isEmpty {
                ContentUnavailableView("No transactions yet", systemImage: "tray").frame(height: 200)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recentTransactions.prefix(5))) { gig in
                        TransactionRow(gig: gig)
                        if gig.id != recentTransactions.prefix(5).last?.id { Divider() }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16)
            .fill(darkMode ? Color(uiColor: .secondarySystemGroupedBackground) : .white))
        .padding(.horizontal)
        .shadow( radius: 5)
    }
}

struct TransactionRow: View {
    let gig: Gig
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(gig.title).font(.subheadline.bold())
                Text(gig.deadline.formatted(date: .abbreviated, time: .omitted)).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(gig.amount, format: .currency(code: "USD")).font(.subheadline.bold()).foregroundStyle(gig.status == .completed ? Color.primary : Color.orange)
                Text(gig.status.rawValue.capitalized).font(.system(size: 10, weight: .bold)).padding(.horizontal, 6).padding(.vertical, 2).background((gig.status == .completed ? Color.green : Color.orange).opacity(0.1)).foregroundStyle(gig.status == .completed ? .green : .orange).clipShape(Capsule())
            }
        }
        .padding(.vertical, 12)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.subheadline).bold().foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.largeTitle).bold().frame(maxWidth: .infinity)
            Spacer()
        }
        .padding()
        .frame(height: 120)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

