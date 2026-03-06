import SwiftUI

struct Gig: Identifiable {
    let id = UUID()
    var title: String
    var dueDate: Date
    var isCompleted = false
    var estimatedHours: Int
}

struct DashboardPage: View {
    
    @State var earnings: Double = 0.0
    @State private var activeItems = 2
    @State private var pendingItems = 6
    
    @State var gigs: [Gig] = [
        Gig(title: "Edit Video for John", dueDate: Date(), estimatedHours: 2),
        Gig(title: "Write Blog Post", dueDate: Date(), isCompleted: true, estimatedHours: 1),
        Gig(title: "Design Poster", dueDate: Date(), isCompleted: false, estimatedHours: 3),
        Gig(title: "Client Meeting", dueDate: Date(), isCompleted: false, estimatedHours: 1),
        Gig(title: "Upload YouTube Video", dueDate: Date(), isCompleted: false, estimatedHours: 2)
    ]
    
    var upcomingGigs: [Gig] {
        gigs
            .filter { !$0.isCompleted }
            .sorted { $0.dueDate < $1.dueDate }
    }
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    // Earnings Card
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Earnings This Month:")
                            .bold()
                            .font(.headline)
                        
                        Text("$\(earnings, specifier: "%.2f")")
                            .font(.largeTitle)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    
                    // Today's Tasks Card
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack {
                            Text("Today's Tasks")
                                .bold()
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink {
                                DashboardPage()
                            } label: {
                                Text("See All >")
                                    .bold()
                                    .foregroundStyle(.black)
                                    .font(.headline)
                            }
                        }
                        
                        Divider()
                        
                        List {
                            ForEach($gigs) { $gig in
                                
                                VStack(spacing: 0) {
                                    
                                    HStack {
                                        
                                        Button {
                                            gig.isCompleted.toggle()
                                        } label: {
                                            Image(systemName: gig.isCompleted ? "checkmark.square" : "square")
                                                .foregroundColor(gig.isCompleted ? .green : .gray)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(gig.title)
                                                .font(.headline)
                                            
                                            Text("Due Today • \(gig.estimatedHours)h")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        //                                        Image(systemName: "chevron.right")
                                        //                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 1)
                                    
                                    //                                    Divider()
                                }
                                //                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .frame(height: 220)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(radius: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    
                    // Upcoming Deadlines Card
                    VStack {
                        ZStack(alignment: .top) {
                            
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .frame(height: 285)
                                .shadow(radius: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            
                            VStack(alignment: .leading, spacing: 12) {
                                
                                // Header
                                HStack {
                                    Text("Upcoming Deadlines")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    NavigationLink {
                                        Text("All Upcoming Gigs")
                                    } label: {
                                        Text("See all >")
                                            .font(.headline)
                                            .foregroundStyle(.black)
                                            .bold()
                                    }
                                }
                                
                                Divider()
                                List{
                                    
                                    ForEach(upcomingGigs) { gig in
                                        HStack {
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(gig.title)
                                                    .font(.headline)
                                                
                                                Text(gig.dueDate, style: .date)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("\(gig.estimatedHours)h")
                                                .font(.caption)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(6)
                                        }
                                        .padding(.vertical, 1)
                                    }
                                }
                                .listStyle(.plain)
                            }
                            .padding()
                            
                        }
                        .padding(.horizontal)
                        
                        
                        HStack{
                            // Active gigs
                            ZStack(alignment: .topLeading){
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: 180, height: 180)
                                    .foregroundStyle(.white)
                                    .shadow(radius: 10)
                                    .overlay(RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray, lineWidth: 1)
                                    )
                                VStack(alignment: .leading){
                                    Text("Active gigs")
                                        .bold()
                                        .padding()
                                    
                                    
                                    HStack{
                                        Image(systemName:"clock.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .padding()
                                        
                                        Text("Active:")
                                            .bold()
                                            .font(.title2)
                                    }
                                    
                                    
                                }
                                Text("\(activeItems)")
                                    .font(.largeTitle)
                                    .bold()
                                    .offset(x: 125, y: 120)
                                
                            }
                            // Pending Payments
                            ZStack(alignment: .topLeading){
                                
                                RoundedRectangle(cornerRadius: 16)
                                
                                    .frame(width: 180, height: 180)
                                    .foregroundStyle(.white)
                                    .shadow(radius: 10)
                                    .overlay(RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray, lineWidth: 1)
                                    )
                                
                                VStack(alignment: .leading){
                                    Text("Pending Payments")
                                        .padding()
                                        .bold()
                                    
                                    
                                    HStack{
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .offset(x: 12, y: 15)
                                        
                                        
                                        Text("Pending:")
                                            .bold()
                                            .font(.title2)
                                            .offset(x: 15, y: 17)
                                        
                                    }
                                    Text("\(pendingItems)")
                                        .font(.largeTitle)
                                        .bold()
                                        .offset(x: 130, y: -2)
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                        
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}
#Preview {
    DashboardPage()
}
