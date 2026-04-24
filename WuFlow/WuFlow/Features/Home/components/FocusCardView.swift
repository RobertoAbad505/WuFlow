//
//  FocusCardView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/23/26.
//
import SwiftUI

struct FocusCardView: View {
    
    let activity: Activity
    let action: () -> Void
    
    var progress: Double {
        activity.todayProgress
    }
    
    var progressRatio: Double {
        min(progress / activity.goalValue, 1)
    }
    
    var body: some View {
        Button(action: action) {
            
            VStack(alignment: .leading, spacing: 12) {
                
                // Icon
                Image(systemName: activity.iconName ?? "circle.dotted")
                    .font(.system(size: 22))
                
                // Name
                Text(activity.name)
                    .font(.headline)
                    .lineLimit(1)
                
                // Progress text
                Text("\(Int(progress)) / \(Int(activity.goalValue)) \(activity.unitType.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Progress bar
                ProgressView(value: progressRatio)
                    .tint(colorForActivity())
            }
            .padding()
            .frame(width: 180, height: 140)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
    }
    
    func colorForActivity() -> Color {
        if progressRatio >= 1 {
            return .green
        } else if progressRatio > 0 {
            return .orange
        } else {
            return .gray
        }
    }
}
