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
    
    var totalEarned: Double {
        if selectedPeriod == .monthly {
            return data.gigs.filter { $0.deadline.isInCurrentMonth }.reduce(0) { $0 + $1.amount }
        } else {
            return data.gigs.filter { $0.deadline.isInCurrentYear }.reduce(0) { $0 + $1.amount }
        }
    }
    
    var pieData: [PieSegment] {
        let paid = data.gigs.filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
        let pending = data.gigs.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
        
        
        return [
            PieSegment(category: "Paid", amount: paid, color: .green),
            PieSegment(category: "Pending", amount: pending, color: .orange)
        ]
    }
    
    var body: some View {
        ZStack{
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 12){
                
                
                VStack{
                    Picker("Earnings Period", selection: $selectedPeriod){
                        
                        ForEach(EarningsPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
                
                ScrollView{
                    VStack{
                        RoundedRectangle(cornerRadius: 16)
                            .frame(height: 320)
                            .padding()
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                            .overlay(alignment: .topLeading) {
                                VStack(alignment: .leading, spacing: 12) {
                                    
                                    Text("Total Earned")
                                        .font(.title2)
                                        .bold()
                                        .foregroundStyle(.black)
                                    
                                    Text("$\(String(format: "%.2f", totalEarned))")
                                        .font(.system(size: 40, weight: .bold))
                                        .padding(.bottom, 4)
                                    
                                    HStack(spacing: 20) {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(.green)
                                                .frame(width: 8, height: 8)
                                            Text("Paid: $1,800")
                                                .font(.footnote)
                                                .foregroundStyle(.green)
                                        }
                                        
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(.orange)
                                                .frame(width: 8, height: 8)
                                            Text("Pending: $350")
                                                .font(.footnote)
                                                .foregroundStyle(.orange)
                                        }
                                    }
                                    
                                    Spacer(minLength: 20)
                                    
                                    //  Bar Chart
                                    Chart {
                                        BarMark(x: .value("Week", "Week 1"), y: .value("Amount", 400))
                                        BarMark(x: .value("Week", "Week 2"), y: .value("Amount", 750))
                                        BarMark(x: .value("Week", "Week 3"), y: .value("Amount", 900))
                                        BarMark(x: .value("Week", "Week 4"), y: .value("Amount", 820))
                                        BarMark(x: .value("Week", "Week 5"), y: .value("Amount", 500))
                                    }
                                    .foregroundStyle(.gray)
                                    .frame(height: 120)
                                    .chartXAxis {
                                        AxisMarks(values: .automatic) { _ in
                                            AxisValueLabel()
                                                .font(.caption2.bold())
                                                .foregroundStyle(.black)
                                        }
                                    }
                                    
                                    .chartYAxis {
                                        AxisMarks(position: .leading, values: .automatic) { value in
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                                .foregroundStyle(.gray.opacity(0.2))
                                            
                                            AxisValueLabel {
                                                if let amount = value.as(Double.self) {
                                                    Text("$\(Int(amount))")
                                                        .font(.caption2.bold())
                                                        .foregroundStyle(.black)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(24)
                            }
                        Color.clear.frame(height: 50)
                        VStack(alignment: .leading, spacing: 20) {
                            // 1. Your Header
                            Text("Payment Status")
                                .font(.title2)
                                .bold()

                            // 2. The Chart and Legend Row
                            HStack(spacing: 30) {
                                
                                // Donut Chart
                                Chart {
                                    ForEach(pieData) { segment in
                                        SectorMark(
                                            angle: .value("Amount", segment.amount),
                                            innerRadius: .ratio(0.65), 
                                            angularInset: 2
                                        )
                                        .foregroundStyle(segment.color)
                                        .cornerRadius(6)
                                    }
                                }
                                .frame(width: 140, height: 140)

                         
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(pieData) { segment in
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(segment.color)
                                                .frame(width: 10, height: 10)
                                            
                                            Text(segment.category)
                                                .font(.callout)
                                                .foregroundStyle(.secondary)
                                            
                                            Spacer()
                                            
                                            Text("$\(Int(segment.amount))")
                                                .font(.callout.bold())
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        
                      
                        
                    }
                    .padding(.top, 16)
                    
                    
                }
            }
            .padding(.vertical, 10)
            .background(Color(UIColor.systemGray6))
            
            
        }
    }
}


#Preview {
    Earnings()
        .environment(GigData())
}
