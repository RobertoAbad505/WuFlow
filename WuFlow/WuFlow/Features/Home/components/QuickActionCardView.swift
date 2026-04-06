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
        Button(action: action.action) {
            VStack(spacing: 10) {
                
                Image(systemName: action.systemImage)
                    .font(.title2)
                    .padding(10)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text(action.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(14)
        }
        
    }
}

#Preview {
    QuickActionCardView(action: .init(title: "Test", systemImage: "star", action: {} ))
}
