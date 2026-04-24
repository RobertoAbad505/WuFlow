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
    ]
    var body: some View {
        VStack {
            ZStack {
                AnimatedBackgroundView(style: .wuFlow)
                    .ignoresSafeArea()
                content
            }
            .sheet(isPresented: $toggleCreateActivity, content: {
                CreateActivityView(mode: .create)
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
                        Label("Add Item", systemImage: "plus.circle.dashed")
                    }
                }
            }
        }
        .navigationTitle("All my activities")
    }
    private var content: some View {
        ScrollView {
            VStack {
                headerSection
                highlights
                activityList
                addActivityBtn
            }
            .padding()
        }
    }
    var activityList: some View {
        LazyVGrid(columns: columns, spacing: 36) {
            ForEach(items) { item in
                NavigationLink(value: item) {
                    ActivityRowCard(activity: item)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 5, y: 10)
                }
            }
            .onDelete(perform: deleteItems)
        }
    }
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Track what matters. Every step counts!")
                .font(.caption)
        }
    }
    private var highlights: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                ActivitiesHighlightView(systemNameImage: "figure.run.square.stack",
                                        count: items.count.description,
                                        description: "Activities",
                                        footnote: "Total",
                                        tint: .blue
                )
                ActivitiesHighlightView(systemNameImage: "flame",
                                        count: calculateGlobalStreak().description,
                                        description: getStreakMessage(),
                                        footnote: "Strike",
                                        tint: .green
                )
                ActivitiesHighlightView(systemNameImage: "figure.run.square.stack",
                                        count: items.count.description,
                                        description: "Activities",
                                        footnote: "Total",
                                        tint: .purple
                )
            }
            Divider()
        }
        .padding(.vertical)
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
    var addActivityBtn: some View {
        HStack {
            Text("🌱")
                .font(.system(size: 30))
            VStack(alignment: .leading) {
                Text("New goal, new you!")
                    .font(.system(size: 14, weight: .bold))
                Text("Create a new activity, to keep growing")
                    .font(.system(size: 12, weight: .none))
            }
            Spacer()
            Button(action: addItem) {
                HStack {
                    Text("Create")
                    Image(systemName: "plus")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 10)
                .background(Color.green)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 2)
            }
        }
        .padding()
        .background(Color.green.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 2)
        }
        .padding(.vertical)
        .padding(.bottom, 50)
    }
    func calculateGlobalStreak() -> Int {
        let calendar = Calendar.current
        
        var streak = 0
        var date = Date()
        
        while true {
            let hasProgress = self.items.contains { activity in
                activity.progressRecords.contains {
                    calendar.isDate($0.date, inSameDayAs: date)
                }
            }
            
            if hasProgress {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        
        return streak
    }
    func getStreakMessage() -> String {
        switch calculateGlobalStreak() {
        case 0:
            return "streaks yet"
        case 1:
            return "day streak!"
        default:
            return "streak days!"
        }
    }
}


#Preview {
    ActivityListView()
        .modelContainer(for: Activity.self, inMemory: false)
}



