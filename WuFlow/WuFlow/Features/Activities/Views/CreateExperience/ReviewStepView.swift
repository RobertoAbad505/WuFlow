//
//  ReviewStepView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/22/26.
//
import SwiftUI

struct ReviewStepView: View {
    
    let draft: ActivityDraft
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                header
                
                summaryCard
                
            }
            .padding()
        }
    }
    private var header: some View {
        VStack(spacing: 8) {
            Text("Review your activity")
                .font(.title2)
            
            Text("Make sure everything feels right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    private var summaryCard: some View {
        VStack(spacing: 20) {
            
            identitySection
            
            Divider()
            
            intentionSection
            
            Divider()
            
            lifeAreaSection
            
            if draft.type != .maintain {
                Divider()
                goalSection
            }
            
            if !draft.motivationDescription.isEmpty {
                Divider()
                motivationSection
            }
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    private var identitySection: some View {
        VStack(spacing: 12) {
            
            ZStack {
                if let data = draft.imageData,
                   let uiImage = UIImage(data: data) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
                } else {
                    Image(systemName: draft.iconName)
                        .font(.system(size: 40))
                        .frame(width: 100, height: 100)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            
            Text(draft.name)
                .font(.headline)
        }
    }
    private var intentionSection: some View {
        HStack {
            Image(systemName: iconForType)
            Text(titleForType)
            Spacer()
        }
    }
    private var titleForType: String {
        switch draft.type {
        case .increase: return "Build"
        case .decrease: return "Reduce"
        case .maintain: return "Flow"
        }
    }

    private var iconForType: String {
        switch draft.type {
        case .increase: return "leaf.fill"
        case .decrease: return "flame.fill"
        case .maintain: return "waveform.path.ecg"
        }
    }
    private var lifeAreaSection: some View {
        HStack {
            Image(systemName: draft.lifeArea.iconName)
                .foregroundColor(draft.lifeArea.color)
            
            Text(draft.lifeArea.title)
            
            Spacer()
        }
    }
    private var goalSection: some View {
        HStack {
            Text(goalText)
            Spacer()
        }
    }
    private var goalText: String {
        switch draft.type {
        case .increase:
            return "At least \(Int(draft.goalValue)) \(draft.unitType.rawValue) per day"
        case .decrease:
            return "No more than \(Int(draft.goalValue)) \(draft.unitType.rawValue)"
        case .maintain:
            return ""
        }
    }
    private var motivationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why this matters")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(draft.motivationDescription)
                .font(.body)
        }
    }
}
