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
            VStack(alignment: .center, spacing: 10) {
                // Icon
                Image(systemName: activity.iconName ?? "circle.dotted")
                    .font(.system(size: 22))
//                    .tint(.black)
                
                // Name
                Text(activity.name)
                    .font(.headline)
                    .lineLimit(5)
                    .tint(.black)
                
                // Progress text
                Text("\(activity.progressDescription)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Progress bar
                ProgressView(value: activity.progressRatio)
                    .tint(colorForActivity())
            }
            .padding()
            .frame(width: 160, height: 150)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        if activity.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 16))
                                .rotationEffect(.degrees(45))
                                .tint(.secondary.opacity(0.55))
                        }
                    }
                    .padding(12)
                    Spacer()
                }
            }
        }
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
