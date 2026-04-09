//
//  ActivityItemView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/9/26.
//

import SwiftUI
struct ActivitySelectionGridView: View {
    
    let activities: [Activity]
    let onSelect: (Activity) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Select Activity")
                .font(.title)
                .fontWeight(.medium)
                .padding(.bottom, 50)
            LazyVGrid(columns: columns, spacing: 35) {
                ForEach(activities) { activity in
                    Button {
                        onSelect(activity)
                    } label: {
                        ActivityCircleView(activity: activity)
                    }
                    .buttonStyle(.plain)
                    .glassEffect()
                }
            }
        }
        .padding()
    }
}
struct ActivityCircleView: View {
    
    let activity: Activity
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: activity.iconName)
                .font(.system(size: 40))
                .foregroundStyle(.primary)
            
            Text(activity.name)
                .font(.system(size: 12))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding()
        .frame(width: 150, height: 150)
    }
}

#Preview {
    ActivitySelectionGridView(activities: [
        Activity(name: "Test",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual),
        Activity(name: "Test2",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual),
        Activity(name: "Test",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual),
        Activity(name: "Test2",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual),
        Activity(name: "Test",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual),
        Activity(name: "Test2",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual)
                                                    
    ],
                                                onSelect: { _ in })
}
