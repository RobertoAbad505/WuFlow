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
        LazyVGrid(columns: columns, spacing: 25) {
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
        VStack {
            ActivityImageView(path: activity.imagePath, icon: activity.iconName)
        }
        .frame(width: 160, height: 195)
        .overlay { infoSquare }
        .background(.clear)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    var infoSquare: some View {
        VStack {
            Spacer()
            HStack {
                Text(activity.name)
                    .font(.system(size: 11).bold())
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)                    
                    .frame(maxWidth: .infinity, maxHeight: 32)
            }
            .background(.ultraThinMaterial)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    let path = try? ImageStore.shared.save(UIImage(named: "selfie") ?? UIImage(),
                                           category: .activity)
    let items = [
        Activity(name: "Test",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual,
                 imagePath: path
                ),
        Activity(name: "Test2",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual,
                 imagePath: path),
        Activity(name: "Test3xxxxxxxxxxxxxxxx xxxxxxxxxxx xxxx xxxxxx",
                 unitType: .count,
                 goalValue: 25,
                 trackingType: .manual,
                 imagePath: path),
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
                 trackingType: .manual,
                 imagePath: path)
                                                    
    ]
    ZStack {
        AnimatedBackgroundView(style: .focus)
        ActivitySelectionGridView(activities: items,
                                  onSelect: { _ in })
    }
}
