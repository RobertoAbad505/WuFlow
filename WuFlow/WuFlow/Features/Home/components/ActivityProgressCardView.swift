//
//  ActivityProgressCardView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/6/26.
//

import SwiftUI

struct ActivityProgressCardView: View {
    
    let activity: Activity
    let progress: Double
    let onTap: (Activity) -> Void
    var progressRatio: Double {
        min(progress / activity.goalValue, 1.0)
    }
    
    var body: some View {
        Button(action: {
            onTap(activity)
        }, label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack {
                        Image(systemName: activity.iconName)
                            .symbolEffect(.rotate)
                            .font(.system(size: 30))
                            .foregroundStyle(.black)
                    }
                    VStack (alignment: .leading, spacing: 5) {
                        Text(activity.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                        Text("\(progress, specifier: "%.0f") / \(activity.goalValue, specifier: "%.0f") \(activity.unitType.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                ProgressView(value: progressRatio)
                    .tint(Color.colorForActivity(activity))
                    .scaleEffect(x: 1, y: 1.2, anchor: .center)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        })
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.18), radius: 5, x: 14, y: 12)
    }
}

#Preview {
    ZStack {
        Color.pink.opacity(0.3).ignoresSafeArea()
        ActivityProgressCardView(activity: Activity(name: "Correr",
                                                    unitType: .minutes,
                                                    goalValue: 50,
                                                    trackingType: .healthSteps), progress: 10, onTap: { _ in })
    }
}
