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
    
    var body: some View {
        VStack {
            HomeHeaderView()
            quickGridView
            PinnedActivitiesView(activities: activities)
        }
        .padding()
    }
    var quickGridView: some View {
        VStack {
            QuickActionGridView(actions: [
                QuickAction(
                    title: "Add Progress",
                    systemImage: "plus.circle"
                ) {
                    print("Add Progress tapped")
                },
                
                QuickAction(
                    title: "New Activity",
                    systemImage: "square.and.pencil"
                ) {
                    print("New Activity tapped")
                },
                
                QuickAction(
                    title: "All Activities",
                    systemImage: "list.bullet"
                ) {
                    print("Navigate to list")
                },
                
                QuickAction(
                    title: "Insights",
                    systemImage: "chart.bar"
                ) {
                    print("Open insights")
                }
            ])
        }
    }
}

#Preview {
    HomeView()
}
