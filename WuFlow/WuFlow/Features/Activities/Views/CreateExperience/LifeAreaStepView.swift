//
//  LifeAreaStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct LifeAreaStepView: View {
    
    @Binding var draft: ActivityDraft
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text("Where does this belong?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Choose the area of your life this supports")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(LifeArea.allCases, id: \.self) { area in
                    LifeAreaCard(
                        area: area,
                        isSelected: draft.lifeArea == area
                    ) {
                        draft.lifeArea = area
                    }
                }
            }
        }
        .padding()
    }
}

struct LifeAreaCard: View {
    
    let area: LifeArea
    let isSelected: Bool
    let action: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            
            Image(systemName: area.iconName)
                .font(.system(size: 30))
                .foregroundColor(area.color)
                .symbolEffect(.bounce, value: animate)
            
            Text(area.title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? area.color : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .shadow(
            color: isSelected ? area.color.opacity(0.3) : .clear,
            radius: 10
        )
        .onTapGesture {
            action()
            animate.toggle()
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
#Preview {
    LifeAreaStepView(draft: .constant(ActivityDraft(lifeArea: .health)))
}
