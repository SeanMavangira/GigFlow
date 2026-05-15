//
//  Gigs.swift
//  GigFlow
//
//  Created by Sean Mavangira on 19/3/2026.
//

import SwiftUI

struct Gigs: View {
    @AppStorage("deadlineAlerts") var deadlineAlerts = true
    @State var selectedStatus: GigStatus = .all
    @State private var isPaid = false
    @State private var showSheet = false
    @State private var title = ""
    @State private var clientName = ""
    @State private var dueDate = Date()
    @State private var selectedGigStatus: GigPicker = .draft
    @State private var amountString = ""
    @State private var isHourly = false
    @State private var deadlineDate = Date()
    @Environment(GigData.self) private var data
    @State private var editingGig: Gig?
    
    var filteredGigs: [Gig] {
        if selectedStatus == .all {
            return data.gigs
        } else {
            return data.gigs.filter { $0.status.rawValue == selectedStatus.rawValue }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Filter Picker
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(filteredGigs) { gig in
                            // --- CALCULATION LOGIC ---
                            // Check if this specific gig is the one selected in the Timer page
                            let isSelectedInTimer = (data.selectedGig?.id == gig.id)
                            
                            // If it's selected, we add the current running session time (data.timeDone)
                            let currentLiveSeconds = gig.timeSpentInSeconds + (isSelectedInTimer ? Double(data.timeDone) : 0.0)
                            
                            GigCard(gig: gig, liveSeconds: currentLiveSeconds) {
                                // EDIT BUTTON ACTION
                                self.editingGig = gig
                                self.title = gig.title
                                self.clientName = gig.clientName
                                self.deadlineDate = gig.deadline
                                self.selectedGigStatus = gig.status
                                
                                switch gig.payType {
                                case .fixed(let amt):
                                    self.amountString = String(format: "%.2f", amt)
                                    self.isHourly = false
                                case .hourly(let rate):
                                    self.amountString = String(format: "%.2f", rate)
                                    self.isHourly = true
                                }
                                self.showSheet = true
                            }
                        }
                        Color.clear.frame(height: 100)
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
            // Your existing NavigationStack / Form code stays exactly as it was
            NavigationStack {
                Form {
                    Section(header: Text("Details")) {
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
                    Section(header: Text("Deadline")) {
                        DatePicker("Select Date", selection: $deadlineDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
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
                            if isHourly { Text("/ hr").foregroundColor(.secondary) }
                        }
                    }
                }
                .navigationTitle(editingGig == nil ? "New Gig" : "Edit Gig")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { Button("Cancel") { showSheet = false } }
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
    
    // FORM HELPERS
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
        // 1. Convert the String amount to a Double (defaults to 0.0 if empty/invalid)
        let finalAmount = Double(amountString) ?? 0.0
        
        // 2. Determine the PayType based on the segmented picker state
        let finalPayType: PayType = isHourly ? .hourly(rate: finalAmount) : .fixed(amount: finalAmount)
        
        // 3. Logic for the isPaid boolean
        let markedAsPaid = (selectedGigStatus == .completed)
        
        if let gig = editingGig {
            // --- EDITING EXISTING GIG ---
            var updated = gig
            updated.title = title
            updated.clientName = clientName
            updated.deadline = deadlineDate
            updated.status = selectedGigStatus
            updated.payType = finalPayType
            updated.isPaid = markedAsPaid
            
            // Push the update to your Data class (triggers save automatically)
            data.update(updated)
            
            // Handle Notifications for edits
            if deadlineAlerts && selectedGigStatus == .active {
                NotificationManager.shared.scheduleDeadlineReminder(for: updated)
            }
            
        } else {
            // --- CREATING NEW GIG ---
            let newGig = Gig(
                title: title,
                clientName: clientName,
                deadline: deadlineDate,
                status: selectedGigStatus,
                payType: finalPayType,
                timeSpentInSeconds: 0, // Fresh gigs start at zero
                isPaid: markedAsPaid
            )
            
            // Use your helper method to append and save
            data.addGig(newGig)
            
            // Handle Notifications for new gigs
            if deadlineAlerts && selectedGigStatus == .active {
                NotificationManager.shared.scheduleDeadlineReminder(for: newGig)
            }
        }
    }
    
    var isFormInvalid: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty ||
        clientName.trimmingCharacters(in: .whitespaces).isEmpty ||
        amountString.isEmpty
    }
}

#Preview {
    Gigs()
        .environment(GigData())
}
