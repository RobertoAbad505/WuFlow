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
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(strokeColor, lineWidth: 2)
        }
    }
    
    private var label: String {
        switch status {
        case .notStarted: return "Not started"
        case .inProgress: return "In progress"
        case .completed: return "Completed"
        case .exceeded: return "Exceeded"
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
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .exceeded: return .orange
        }
    }
    private var strokeColor: Color {
        switch status {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .exceeded: return .green
        }
    }
}
