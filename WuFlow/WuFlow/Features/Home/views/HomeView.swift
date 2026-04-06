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
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Image("plantBackground")
                    .resizable()
                    .ignoresSafeArea() // 🔥 fills entire screen
                
                // Content layer
                content
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .activityList:
                    ActivityListView()
                    
                case .activityDetail(let activity):
                    ActivityDetailView(activity: activity)
                    
                case .addActivity:
                    CreateActivityView()
                    
                case .addProgress(let activity):
                    AddActivityProgressView(activity: activity)
                    
                case .insights:
                    ActivityListView()
                }
            }
        }
    }
    var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                HomeHeaderView()
                
                quickGridView
                
                PinnedActivitiesView(activities: activities) {
                    path.append(AppRoute.activityDetail($0))
                }
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
        if let first = activities.first {
            actionsList.append(QuickAction(
                title: "Add Progress",
                systemImage: "plus.circle",
                route: .addProgress(first)
            ))
        }
        actionsList.append(contentsOf: [
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
            )
        ])
        
        return actionsList
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Activity.self, inMemory: false)
}
