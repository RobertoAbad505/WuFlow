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
                Text("\(activity.progressDescription)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Progress bar
                ProgressView(value: activity.progressRatio)
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
        if activity.progressRatio >= 1 {
            return .green
        } else if activity.progressRatio > 0 {
            return .orange
        } else {
            return .gray
        }
    }
}
