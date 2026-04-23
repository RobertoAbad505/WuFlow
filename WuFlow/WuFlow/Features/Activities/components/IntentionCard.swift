//
//  IntentionCard.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct IntentionCard: View {
    
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: 16) {
            
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .symbolEffect(.bounce, value: animate)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(color)
                    .symbolEffect(.bounce, value: isSelected)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? color : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .onTapGesture {
            action()
            animate.toggle()
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
