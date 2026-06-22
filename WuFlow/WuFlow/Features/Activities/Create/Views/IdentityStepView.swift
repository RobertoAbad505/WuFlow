//
//  IdentityStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct IdentityStepView: View {
    
    @Binding var draft: ActivityDraft
    
    let icons: [String] = [
        // Health
        "heart.fill", "figure.walk", "figure.run", "figure.strengthtraining.traditional",
        
        // Mind
        "brain.head.profile", "sparkles",
//        "moon.stars.fill",
        
        // Growth
        "book.fill", "graduationcap.fill", "lightbulb.fill",
        
        // Work
        "briefcase.fill", "laptopcomputer",
//        "hammer.fill",
        
        // Social
        "person.2.fill","bubble.left.and.bubble.right.fill",
        
        // Leisure
        "leaf.fill", "gamecontroller.fill", "music.note",
        
        // General
        "flame.fill", "star.fill", "target", "circle.dotted"
    ]
    
    var body: some View {
        VStack(spacing: 25) {
            
            Text("What do you want to grow?")
                .font(.title2)
            
            // Preview
            Image(systemName: draft.iconName)
                .symbolEffect(.bounce)
                .font(.system(size: 40))
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Circle())
            
            // Name input
            TextField("Activity name", text: $draft.name)
                .textFieldStyle(.roundedBorder)
                .font(.headline)
            
            Text("Choose a symbol")
                .font(.subheadline)
                .foregroundColor(.secondary)
            // Icon grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(icons, id: \.self) { icon in
                    IconCell(
                        icon: icon,
                        isSelected: draft.iconName == icon
                    ) {
                        draft.iconName = icon
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        IdentityStepView(draft: .constant(ActivityDraft(from: Activity(name: "Test",
                                                             unitType: .count,
                                                             goalValue: 25,
                                                             trackingType: .manual))))
    }
    .padding()
}
