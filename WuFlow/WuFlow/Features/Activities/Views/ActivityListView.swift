////  ActivityListView.swift
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
    
    //ON DELETE
    @State var showDeleteAlert = false
    @State private var selectedToDelete: Activity?
    @State private var showDeleteDialog = false
    
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
            .fullScreenCover(isPresented: $toggleCreateActivity, content: {
                CreateActivityView(mode: .create)
            })
            .navigationDestination(for: Activity.self) { selectedItem in
                ActivityDetailView(activity: selectedItem)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        }
    }
    private var content: some View {
        ScrollView {
            VStack {
                headerSection
                highlights
                activityList
                addActivityBtn
                Button(action: NotificationManager.shared
                    .printPendingNotifications, label: {
                        Text("PRINT PENDING NOTIFICATIONS")
                            .padding(10)
                    })
                .buttonStyle(.glass)
                resyncAllNotifications
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
        }
    }
    var resyncAllNotifications: some View {
        Button(action: {
            NotificationManager.shared.syncReminders(for: self.items)
        }, label: {
            Text("Resync all notifications!")
        })
        .buttonStyle(.glass)
    }
    var activityList: some View {
        LazyVGrid(columns: columns, spacing: 36) {
            ForEach(items) { item in
                NavigationLink(value: item) {
                    ActivityRowCard(activity: item)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 5, y: 10)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        selectedToDelete = item
                        showDeleteDialog = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete Activity?",
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let activity = selectedToDelete {
                    delete(activity)
                }
            }
            
            Button("Cancel", role: .cancel) {
                selectedToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
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
                Button(action: addItem) {
                    VStack {
                        Image(systemName: "plus.square.dashed")
                            .font(.system(size: 32))
                        Text("Add new activity")
                            .font(.system(size: 10, weight: .regular))
                    }
                    .padding(.horizontal, 20)
                    .frame(maxHeight: .infinity)
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white, lineWidth: 2)
                    }
                }
                .tint(.green)
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
//                ActivitiesHighlightView(systemNameImage: "figure.run.square.stack",
//                                        count: items.count.description,
//                                        description: "Activities",
//                                        footnote: "Total",
//                                        tint: .purple
//                )
            }
            .frame(maxHeight: .infinity)
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

    private func delete(_ activity: Activity) {
        withAnimation {
            modelContext.delete(activity)
            
            do {
                try modelContext.save()
            } catch {
                print("❌ Delete failed:", error)
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        selectedToDelete = nil
    }
}


#Preview("Activity List") {
    // Seed initial data into an in-memory model container so @Query works in previews
    let previewItems = [
        Activity(name: "GYM", unitType: .count, goalValue: 20, trackingType: .manual),
        Activity(name: "Meditation", unitType: .count, goalValue: 20, trackingType: .manual),
        Activity(name: "Push-ups", unitType: .count, goalValue: 20, trackingType: .manual)
    ]
    NavigationStack {
        ActivityListView(toggleCreateActivity: false)
            .modelContainer(for: Activity.self, inMemory: true) { result in
                if case let .success(container) = result {
                    let context = container.mainContext
                    previewItems.forEach { context.insert($0) }
                    try? context.save()
                }
            }
    }
}
