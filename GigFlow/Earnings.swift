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
                            .frame(width: 380, height: 320)
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                            .overlay(alignment: .topLeading) {
                                VStack(alignment: .leading, spacing: 12) {
                                    
                                    Text("Total Earned")
                                        .font(.title2)
                                        .bold()
                                        .foregroundStyle(.black)
                                    
                                    Text("$\(String(format: "%.2f", 2150.00))")
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
                                    
                                    // 4. Bar Chart
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
                        VStack(alignment: .leading){
                            Text("Payment Status")
                                .font(.title2)
                                .bold()
                            
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
