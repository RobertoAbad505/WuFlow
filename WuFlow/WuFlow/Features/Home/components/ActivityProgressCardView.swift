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
    
    var progressRatio: Double {
        min(progress / activity.goalValue, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Text(activity.name)
                .font(.headline)
            
            Text("\(progress, specifier: "%.0f") / \(activity.goalValue, specifier: "%.0f") \(activity.unitType.rawValue)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: progressRatio)
                .tint(colorForActivity())
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(14)
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
                                                trackingType: .healthSteps), progress: 10)
}
