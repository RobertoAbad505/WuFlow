//
//  ActivityListView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import SwiftUI
import SwiftData

struct ActivityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Activity]

    @State var toggleCreateActivity: Bool = false
    private let columns = [
        GridItem(.flexible())
//        GridItem(.flexible())
    ]
    var body: some View {
        VStack {
            ZStack {
                AnimatedBackgroundView(style: .wuFlow)
                    .ignoresSafeArea()
                content
            }
            .sheet(isPresented: $toggleCreateActivity, content: {
                CreateActivityView()
            })
            .navigationDestination(for: Activity.self) { selectedItem in
                ActivityDetailView(activity: selectedItem)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
    private var content: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("All my activities")
                        .font(Font.title.weight(.bold))
                    Spacer()
                    Button(action: addItem) {
                        Image(systemName: "plus")
                    }
                }
                LazyVGrid(columns: columns, spacing: 36) {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            VStack(alignment: .center) {
                                Image(systemName: item.iconName)
                                    .font(.system(size: 32))
                                Text(item.name)
                                    .font(.system(size: 14))
                            }
                            .frame(minWidth: 150, minHeight: 40)
                            .padding(50)
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.5), radius: 15, x: 8, y: 15)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .padding()
        }
    }

    private func addItem() {
        withAnimation {
            toggleCreateActivity.toggle()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}


#Preview {
    ActivityListView()
        .modelContainer(for: Activity.self, inMemory: false)
}


struct DebugDataSeeder {
    @Environment(\.modelContext) private var modelContext
    
    func deleteAllData() {
        let activities = try? modelContext.fetch(FetchDescriptor<Activity>())
        let records = try? modelContext.fetch(FetchDescriptor<ProgressRecord>())
        
        activities?.forEach { modelContext.delete($0) }
        records?.forEach { modelContext.delete($0) }
    }
    
    static func seedSampleData(context: ModelContext) {
        let activities = try? context.fetch(FetchDescriptor<Activity>())
        activities?.forEach { context.delete($0) }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Create Activity
        let activity = Activity(
            name: "Test Activity",
            unitType: .minutes,
            goalValue: 30,
            trackingType: .manual
        )
        
        context.insert(activity)
        
        // Helper to create dates
        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: now)!
        }
        
        // Sample records
        let sampleData: [(Int, Double)] = [
            (0, 10),  // today
            (0, 5),   // today
            (1, 20),  // yesterday
            (2, 15),  // 2 days ago
            (3, 25),
            (5, 30),
            (7, 18),  // last week
            (8, 22),
            (10, 12),
            (20, 40), // last month-ish
            (25, 35)
        ]
        
        for (daysAgoValue, value) in sampleData {
            let date = daysAgo(daysAgoValue)
            
            let record = ProgressRecord(
                value: value,
                date: date,
                source: .manual,
                activity: activity
            )
            
            activity.progressRecords.append(record)
            context.insert(record)
        }
        
        do {
            try context.save()
            print("✅ Seed data created")
        } catch {
            print("❌ Error seeding data:", error)
        }
    }
}
