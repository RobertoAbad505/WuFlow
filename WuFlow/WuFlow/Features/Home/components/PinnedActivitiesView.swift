//
//  PinnedActivitiesView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/6/26.
//

import SwiftUI

struct PinnedActivitiesView: View {
    
    let activities: [Activity]
//    let progressMap: [UUID: Double]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var progressMap: [UUID: Double] {
        Dictionary(uniqueKeysWithValues: activities.map {
            ($0.id, todayProgress(for: $0))
        })
    }
    init(activities: [Activity]) {
        self.activities = activities
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Your Focus")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(getFeaturedActivities(activities)) { activity in
                    ActivityProgressCardView(
                        activity: activity,
                        progress: progressMap[activity.id] ?? 0
                    )
                }
            }
        }
    }
    func getFeaturedActivities(_ activities: [Activity]) -> [Activity] {
        
        let pinned = activities.filter { $0.isPinned }
        
        if !pinned.isEmpty {
            return Array(pinned.prefix(5))
        }
        
        // fallback → top by progress (or count)
        return Array(activities.prefix(5))
    }
    func todayProgress(for activity: Activity) -> Double {
        let calendar = Calendar.current
        
        return activity.progressRecords
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.value }
    }
}

//#Preview {
//    PinnedActivitiesView(activities: [
//        Activity(name: "Correr",
//                 unitType: .minutes,
//                 goalValue: 50,
//                 trackingType: .healthSteps)
//    ], progressMap: [UUID().uuidString, 50.0])
//}
