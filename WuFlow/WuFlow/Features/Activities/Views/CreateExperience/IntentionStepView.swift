//
//  IntentionStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct IntentionStepView: View {
    
    @Binding var draft: ActivityDraft
    
    var body: some View {
        VStack(spacing: 40) {
            
            Text("What is your intention?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                
                IntentionCard(
                    title: "Build",
                    subtitle: "Grow or improve over time",
                    icon: "leaf.fill",
                    color: .green,
                    isSelected: draft.type == .increase
                ) {
                    draft.type = .increase
                }
                
                IntentionCard(
                    title: "Reduce",
                    subtitle: "Limit or gain control",
                    icon: "flame.fill",
                    color: .orange,
                    isSelected: draft.type == .decrease
                ) {
                    draft.type = .decrease
                }
                
                IntentionCard(
                    title: "Flow",
                    subtitle: "Stay consistent naturally",
                    icon: "water.waves",
                    color: .blue,
                    isSelected: draft.type == .maintain
                ) {
                    draft.type = .maintain
                }
            }
        }
        .padding()
    }
}

#Preview {
    IntentionStepView(draft: .constant(ActivityDraft()))
}
