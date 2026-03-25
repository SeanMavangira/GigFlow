//
//  Gigs.swift
//  GigFlow
//
//  Created by Sean Mavangira on 19/3/2026.
//

import SwiftUI

struct Gigs: View {
    @State private var selectedStatus: GigStatus = .all
    @State private var showSheet = false
    @State private var title = ""
    @State private var clientName = ""
    @State private var dueDate = Date()
    
    @State private var selectedGigStatus: GigPicker = .draft
    @State private var amountString = ""
    @State private var isHourly = false
    @Environment(GigData.self) private var data
    
    @State private var editingGig: Gig?
    
    var filteredGigs: [Gig] {
            if selectedStatus == .all {
                return data.gigs
            } else {
                return data.gigs.filter { $0.status.rawValue == selectedStatus.rawValue }
            }
        }
    
    func resetForm() {
        title = ""
        clientName = ""
        dueDate = Date()
        selectedGigStatus = .draft
        amountString = ""
        isHourly = false
        editingGig = nil
    }
    
   
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()
                
                
                VStack(spacing: 0) {
                    
                    
                    VStack {
                        Picker("Gig Status", selection: $selectedStatus) {
                            ForEach(GigStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemGray6))
                    
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            
                            ForEach(filteredGigs) { gig in
                                GigCard(gig: gig) {
                                    self.title = gig.title
                                    self.clientName = gig.clientName
                                    self.dueDate = gig.deadline
                                    self.selectedGigStatus = gig.status
                                    self.amountString = String(format: "%.2f", gig.amount)
                                    self.isHourly = !gig.payType.isFixed
                                    self.editingGig = gig
                                    self.showSheet = true
                                }
                            }
                            
                            
                            
                            Color.clear.frame(height: 1000)
                        }
                        .padding(.top)
                    }
                    
                    
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    showSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundStyle(.gray)
                        .background(Color.white.clipShape(Circle()))
                        .shadow(radius: 4)
                }
                .padding(.trailing, 25)
                .padding(.bottom, 20)
            }
            .sheet(isPresented: $showSheet) {
                NavigationStack{
                    Form {
                        Section(header: Text("")) {
                            TextField("Title", text: $title)
                            
                        }
                        .frame(minHeight: 30)
                        
                        
                        
                        Section(header: Text("")){
                            TextField("Client Name", text: $clientName)
                            
                        }
                        .frame(minHeight: 30)
                        
                        
                        
                        Section(header: Text("")){
                            DatePicker(
                                "Deadline",
                                selection: $dueDate,
                                in: Date()...,
                                displayedComponents: [.date]
                            )
                        }
                        .frame(minHeight: 30)
                        
                        
                        
                        
                        
                        Section(header: Text("")) {
                            Picker("Gig Status", selection: $selectedGigStatus) {
                                ForEach(GigPicker.allCases) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            
                            .pickerStyle(.navigationLink)
                        }
                        .frame(minHeight: 30)
                        
                        
                        Section(header: Text("Payment")) {
                            
                            Picker("Payment Method", selection: $isHourly) {
                                Text("Fixed Price").tag(false)
                                Text("Hourly Rate").tag(true)
                            }
                            .pickerStyle(.segmented)
                            .padding(.vertical, 5)
                            
                            
                            HStack {
                                Text("$")
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                
                                TextField("0.00", text: $amountString)
                                    .keyboardType(.decimalPad)
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        HStack {
                            Button {
                               
                                let finalAmount = Double(amountString) ?? 0.0
                                
                                
                                let finalPayType: PayType = isHourly ? .hourly(rate: finalAmount) : .fixed(amount: finalAmount)
                                
                                if var gigToUpdate = editingGig {
                                    
                                    gigToUpdate.title = title
                                    gigToUpdate.clientName = clientName
                                    gigToUpdate.deadline = dueDate
                                    gigToUpdate.status = selectedGigStatus
                                    gigToUpdate.amount = finalAmount
                                    gigToUpdate.payType = finalPayType
                                    
                                    data.update(gigToUpdate)
                                } else {
                                    
                                    let newGig = Gig(
                                        title: title,
                                        clientName: clientName,
                                        amount: finalAmount,
                                        deadline: dueDate,
                                        status: selectedGigStatus,
                                        payType: finalPayType
                                    )
                                    data.gigs.append(newGig)
                                }
                                
                                showSheet = false
                                resetForm()
                            } label: {
                                Text(editingGig == nil ? "Add" : "Save")
                                    .font(.headline)
                                    .frame(width: 150, height: 60)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                            .padding()

                            Button {
                                showSheet = false
                            } label: {
                                Text("Cancel") 
                                    .font(.headline)
                                    .frame(width: 150, height: 60)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                        }
                        
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    Gigs()
        .environment(GigData())
}
