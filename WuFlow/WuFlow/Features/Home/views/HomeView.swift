//
//  HomeView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/5/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var activities: [Activity]
    @State private var isPresentedAddProgress: Bool = false
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Image("plantBackground")
                    .resizable()
                    .ignoresSafeArea()
                    .blur(radius: 1)
                content
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .activityList:
                    ActivityListView()
                case .activityDetail(let activity):
                    ActivityDetailView(activity: activity)
                case .addActivity:
                    CreateActivityView(mode: .create)
                case .addProgress(let activity):
                    AddActivityProgressView(activity: activity)
                case .insights:
                    InsightsView()
                }
            }
            .sheet(isPresented: $isPresentedAddProgress) {
                AddActivityProgressView()
            }
        }
    }
    var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                HomeHeaderView()
//                dailySummarySection
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    var quickGridView: some View {
        VStack {
            QuickActionGridView(
                actions: getActions(),
                onActionTap: { route in
                    path.append(route)
                }
            )
        }
    }
    func getActions() -> [QuickAction] {
        var actionsList = [QuickAction]()
        actionsList.append(contentsOf: [
            QuickAction(
                title: "Add Progress",
                systemImage: "plus.circle",
                route: .addProgress(nil)
            ),
            QuickAction(
                title: "New Activity",
                systemImage: "square.and.pencil",
                route: .addActivity
            ),
            QuickAction(
                title: "All Activities",
                systemImage: "list.bullet",
                route: .activityList
            ),
            QuickAction(
                title: "Insights",
                systemImage: "chart.bar",
                route: .insights
            ),
            QuickAction(
                title: "\(calculateGlobalStreak().description)\n Streak days",
                systemImage: "flame",
                route: .insights
            )
        ])
        
        return actionsList
    }
    func calculateGlobalStreak() -> Int {
        let calendar = Calendar.current
        
        var streak = 0
        var date = Date()
        
        while true {
            let hasProgress = self.activities.contains { activity in
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
}
struct InsightsView: View {
    var body: some View {
        Text("Insights coming soon")
    }
}
#Preview {
    HomeView()
        .modelContainer(for: Activity.self, inMemory: false)
}
