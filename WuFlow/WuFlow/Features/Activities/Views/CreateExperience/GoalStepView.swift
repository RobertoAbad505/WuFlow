//
//  GoalStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct GoalStepView: View {
    
    @Binding var draft: ActivityDraft
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text(titleText)
                .font(.title2)
                .multilineTextAlignment(.center)
            
            // VALUE INPUT (only for increase/decrease)
            if draft.type != .maintain {
                valueInput
                quickValues
            } else {
                flowView
            }
            
            unitSelector
        }
        .padding()
    }
    private var titleText: String {
        switch draft.type {
        case .increase:
            return "How much do you want to build daily?"
        case .decrease:
            return "What limit do you want to set?"
        case .maintain:
            return "Just show up consistently 🌊"
        }
    }
    private var valueInput: some View {
        VStack(spacing: 12) {
            
            TextField("0", value: $draft.goalValue, format: .number)
                .keyboardType(.decimalPad)
                .font(.system(size: 48, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text(goalDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    private var unitSelector: some View {
        //Unit type input
        Picker("Unit type", selection: $draft.unitType) {
            ForEach(UnitType.allCases, id: \.self) {
                Text($0.rawValue.capitalized)
            }
        }
        .pickerStyle(.segmented)
    }
    private var goalDescription: String {
        switch draft.type {
        case .increase:
            return "At least this amount per day"
        case .decrease:
            return "No more than this amount"
        case .maintain:
            return ""
        }
    }
    private var flowView: some View {
        VStack(spacing: 12) {
            
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .symbolEffect(.bounce)
            
            Text("Focus on consistency, not quantity")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    private var quickValues: some View {
        HStack(spacing: 12) {
            ForEach([10, 20, 30, 60], id: \.self) { value in
                Button("\(value)") {
                    draft.goalValue = Double(value)
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
        }
    }
}
