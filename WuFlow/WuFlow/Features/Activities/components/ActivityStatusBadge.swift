//
//  ActivityStatusBadge.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/14/26.
//
import SwiftUI

struct ActivityStatusBadge: View {
    
    let status: ActivityStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(label)
                .frame(maxWidth: 100, alignment: .center)
        }
        .font(.caption2.weight(.medium))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .foregroundStyle(color)
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(color.opacity(0.28), lineWidth: 1)
        }
    }
    
    private var label: String {
        switch status {
        case .notStarted: return "Not started"
        case .inProgress: return "In progress"
        case .completed: return "Completed"
        case .exceeded: return "Above goal"
        }
    }
    
    private var icon: String {
        switch status {
        case .notStarted: return "circle"
        case .inProgress: return "clock"
        case .completed: return "checkmark.circle.fill"
        case .exceeded: return "flame.fill"
        }
    }
    
    private var color: Color {
        switch status {
        case .notStarted: return AppColors.secondaryText
        case .inProgress: return AppColors.oceanBlue
        case .completed: return AppColors.midnightNavy
        case .exceeded: return AppColors.kinGold
        }
    }
}
