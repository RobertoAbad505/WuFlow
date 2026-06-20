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
            title
            list
        }
        .padding()
    }
    var title: some View {
        Text("Select an activity")
            .font(.title3)
            .foregroundStyle(.secondary)
            .fontWeight(.medium)            
    }
    var list: some View {
        LazyVGrid(columns: columns, spacing: 35) {
            ForEach(activities) { activity in
                Button {
                    onSelect(activity)
                } label: {
                    ActivityCircleView(activity: activity)
                }
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 15))
            }
        }
    }
}
struct ActivityCircleView: View {
    
    let activity: Activity
    
    var body: some View {
        ZStack {
            ActivityImageView(path: activity.imagePath, icon: activity.iconName)
            infoSquare
        }
        .frame(width: 150, height: 185)
        .background(.clear)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    var infoSquare: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom){
                Text(activity.name)
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    
    let items = [
        Activity(name: "Test",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual),
        Activity(name: "Test2",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual),
        Activity(name: "Test3",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual),
        Activity(name: "Test4",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual),
        Activity(name: "Test5",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual),
        Activity(name: "Test6",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual)
                                                    
    ]
    ZStack {
        AnimatedBackgroundView(style: .focus)
        ActivitySelectionGridView(activities: items,
                                  onSelect: { _ in })
    }
}
