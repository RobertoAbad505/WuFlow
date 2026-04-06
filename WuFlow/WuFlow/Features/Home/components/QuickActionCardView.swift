//
//  QuickActionCardView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/5/26.
//

import SwiftUI

struct QuickActionCardView: View {
    let action: QuickAction
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: action.systemImage)
                .font(.title3)
                .foregroundStyle(.primary)
                .padding(10)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            Text(action.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .padding()
    }
}

#Preview {
    QuickActionCardView(action: .init(title: "Test", systemImage: "star", route: .activityList))
}
