//
//  Gigs.swift
//  GigFlow
//
//  Created by Sean Mavangira on 19/3/2026.
//

import SwiftUI

struct Gigs: View {
    
    @State var selectedStatus: GigStatus = .all
    
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
    
    func saveGig() {
        let finalAmount = Double(amountString) ?? 0.0
        let finalPayType: PayType = isHourly ? .hourly(rate: finalAmount) : .fixed(amount: finalAmount)
        
        if let gig = editingGig {
            
            var updated = gig
            updated.title = title
            updated.clientName = clientName
            updated.deadline = dueDate
            updated.status = selectedGigStatus
            updated.amount = finalAmount
            updated.payType = finalPayType
            data.update(updated)
        } else {
            
            let newGig = Gig(title: title, clientName: clientName, amount: finalAmount, deadline: dueDate, status: selectedGigStatus, payType: finalPayType)
            data.gigs.append(newGig)
        }
    }
    
    var isFormInvalid: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty ||
        clientName.trimmingCharacters(in: .whitespaces).isEmpty ||
        amountString.isEmpty
    }
    
    var body: some View {
        
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Segmented Picker for Filtering
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
                        
                        Color.clear.frame(height: 80)
                    }
                    .padding(.top)
                }
            }
        }
       
        .overlay(alignment: .bottomTrailing) {
            Button {
                resetForm()
                showSheet = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .foregroundStyle(.blue)
                    .background(Color.white.clipShape(Circle()))
                    .shadow(radius: 4)
            }
            .padding(.trailing, 25)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showSheet) {
            
            NavigationStack {
                Form {
                    Section(
                        header: Text("Details"),
                        footer: Text(isFormInvalid ? "Please fill in all fields to save." : "")
                            .foregroundColor(.red)
                    ) {
                        TextField("Title", text: $title)
                        TextField("Client Name", text: $clientName)
                    }
                    
                    Section(header: Text("Status")) {
                        Picker("Gig Status", selection: $selectedGigStatus) {
                            ForEach(GigPicker.allCases) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    
                    Section(header: Text("Payment")) {
                        Picker("Payment Method", selection: $isHourly) {
                            Text("Fixed Price").tag(false)
                            Text("Hourly Rate").tag(true)
                        }
                        .pickerStyle(.segmented)
                        
                        HStack {
                            Text("$").bold().foregroundColor(.secondary)
                            TextField("0.00", text: $amountString)
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                .navigationTitle(editingGig == nil ? "New Gig" : "Edit Gig")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { showSheet = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            saveGig()
                            showSheet = false
                        }
                        .bold()
                        .disabled(isFormInvalid)
                    }
                }
            }
        }
    }
    
    
}

#Preview {
    Gigs()
        .environment(GigData())
}
