//
//  IconCell.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct IconCell: View {
    
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 22))
            .padding(16)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                Circle()
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .onTapGesture {
                action()
                
                // trigger animation
                animate.toggle()
            }
//            .animation(.spring(response: 0.3), value: isSelected)
            .symbolEffect(.bounce, value: isSelected)
            .shadow(color: isSelected ? Color.green.opacity(0.4) : .clear, radius: 8)
    }
}
