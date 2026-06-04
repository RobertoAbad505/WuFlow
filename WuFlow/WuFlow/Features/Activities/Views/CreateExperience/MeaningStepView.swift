//
//  MeaningStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct MeaningStepView: View {
    let mode: ActivityFlowMode
    @Binding var draft: ActivityDraft
    @FocusState private var isFocused: Bool
    @FocusState private var focusedField: Field?
    
    init(draft: Binding<ActivityDraft>,_ mode: ActivityFlowMode) {
        _draft = draft
        self.mode = mode
    }
    
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
                .font(.system(size: 28))
                .foregroundColor(.green)
                .symbolEffect(.pulse, value: draft.motivationDescription)
            optionalSecondary
            
        }
        .padding()
        .onAppear {
            if mode != ActivityFlowMode.create {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .motivation
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {

                Button("Next") {
                    focusedField = .outcome
                }

                Spacer()

                Button("Done") {
                    focusedField = nil
                }
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
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .motivation)
                .frame(height: 120)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
        }
    }
    private var optionalSecondary: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("What do you hope to gain?")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(
                "More energy, clarity, confidence...",
                text: $draft.expectedOutcomeDescription
            )
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    enum Field {
        case motivation
        case outcome
    }

}
