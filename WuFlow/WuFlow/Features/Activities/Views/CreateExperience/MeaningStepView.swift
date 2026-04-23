//
//  MeaningStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct MeaningStepView: View {
    
    @Binding var draft: ActivityDraft
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text("Why does this matter to you?")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("This helps you stay consistent when motivation drops 🌿")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            inputArea
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundColor(.green)
                .symbolEffect(.pulse, value: draft.motivationDescription)
            optionalSecondary
            
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
    private var inputArea: some View {
        ZStack(alignment: .topLeading) {
            
            if draft.motivationDescription.isEmpty {
                Text("I want to feel more focused, calm, and in control...")
                    .foregroundColor(.secondary.opacity(0.6))
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
            }
            
            TextEditor(text: $draft.motivationDescription)
                .focused($isFocused)
                .frame(minHeight: 120)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
        }
    }
    private var optionalSecondary: some View {
        VStack(spacing: 8) {
            
            Text("What do you hope to gain?")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("More energy, clarity, confidence...", text: $draft.expectedOutcomeDescription)
                .textFieldStyle(.roundedBorder)
        }
    }
}

