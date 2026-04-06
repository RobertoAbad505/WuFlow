//
//  QuickActionGridView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/5/26.
//

import SwiftUI

struct QuickActionGridView: View {
    
    let actions: [QuickAction]
    let onActionTap: (AppRoute) -> Void
    
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
                    Button {
                        onActionTap(action.route)
                    } label: {
                        QuickActionCardView(action: action)
                    }
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    QuickActionGridView(actions: [
        .init(title: "Test", systemImage: "star", route: AppRoute.addActivity),
        .init(title: "Test", systemImage: "star", route: AppRoute.addActivity),
        .init(title: "Test", systemImage: "star", route: AppRoute.addActivity),
        .init(title: "Test", systemImage: "star", route: AppRoute.addActivity)
    ], onActionTap: { _ in
        
    })
}
