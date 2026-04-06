//
//  QuickActionGridView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/5/26.
//

import SwiftUI

struct QuickActionGridView: View {
    
    let actions: [QuickAction]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(actions) { action in
                    QuickActionCardView(action: action)
                }
            }
        }
    }
}

#Preview {
    QuickActionGridView(actions: [
        .init(title: "Test", systemImage: "star", action: {} ),
        .init(title: "Test", systemImage: "star", action: {} ),
        .init(title: "Test", systemImage: "star", action: {} ),
        .init(title: "Test", systemImage: "star", action: {} )
    ])
}
