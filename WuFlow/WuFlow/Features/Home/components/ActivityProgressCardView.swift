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
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    VStack{
                        Text(activity.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("\(progress, specifier: "%.0f") / \(activity.goalValue, specifier: "%.0f") \(activity.unitType.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                ProgressView(value: progressRatio)
                    .tint(colorForActivity())
                    .scaleEffect(x: 1, y: 1.2, anchor: .center)
            }
            .padding()
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
        })
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
        .buttonStyle(PlainButtonStyle())
    }
    
    func colorForActivity() -> Color {
        // simple variation
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        return colors[abs(activity.name.hashValue) % colors.count]
    }
}

#Preview {
    ActivityProgressCardView(activity: Activity(name: "Correr",
                                                unitType: .minutes,
                                                goalValue: 50,
                                                trackingType: .healthSteps), progress: 10, onTap: { _ in })
}
