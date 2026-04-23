//
//  CreateActivityView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import SwiftUI
import SwiftData

struct CreateActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var step: CreateActivityStep = .identity
    @State private var draft = ActivityDraft()
     
    @StateObject private var cameraManager = CameraManager()
    let allSteps: [CreateActivityStep] = [
        .identity,
        .intention,
        .lifeArea,
        .goal,
        .meaning,
        .visual,
        .review
    ]
       
    var body: some View {
        VStack {
            stepView
            navigationControls
        }        
        .padding()
    }
    var stepView: some View {
        VStack{
            switch step {
            case .identity:
                IdentityStepView(draft: $draft)
            case .intention:
                IntentionStepView(draft: $draft)                
            case .lifeArea:
                LifeAreaStepView(draft: $draft)
            case .goal:
                GoalStepView(draft: $draft)
            case .meaning:
                MeaningStepView(draft: $draft)
            case .visual:
                VisualStepView(draft: $draft, cameraManager: cameraManager)
            case .review:
                ReviewStepView(draft: draft)
            }
        }
    }
    
    private func saveActivity() {
        withAnimation {
            let imageData = cameraManager.image?.jpegData(compressionQuality: 0.8)
            let newActivity = Activity(
                name: draft.name,
                unitType: draft.unitType,
                goalValue: draft.goalValue,
                trackingType: draft.trackingType,
                iconName: draft.iconName,
                motivationDescription: draft.motivationDescription,
                expectedOutcomeDescription: draft.expectedOutcomeDescription,
                imageData: imageData,
                type: draft.type,
                lifeArea: draft.lifeArea,
                secondaryNote: draft.secondaryNote
            )
            
            modelContext.insert(newActivity)
        }
    }
    func nextStep() -> CreateActivityStep {
        guard let index = allSteps.firstIndex(of: step),
              index < allSteps.count - 1 else {
            return step
        }
        return allSteps[index + 1]
    }

    func previousStep() -> CreateActivityStep {
        guard let index = allSteps.firstIndex(of: step),
              index > 0 else {
            return step
        }
        return allSteps[index - 1]
    }
    func handleNext() {
        if step == .review {
            saveActivity()
            dismiss()
        } else {
            withAnimation {
                step = nextStep()
            }
        }
    }
    var navigationControls: some View {
        HStack(alignment: .top, spacing: 0) {
            
            if step != .identity {
                Button("Back") {
                    withAnimation {
                        step = previousStep()
                    }
                }
            }
            
            Spacer()
            
            Button(step == .review ? "Create" : "Next") {
                handleNext()
            }
        }
        .padding(.horizontal)
    }
    
}

enum CreateActivityStep {
    case identity
    case intention
    case lifeArea
    case goal
    case meaning
    case visual
    case review
}
struct ActivityDraft {
    var name: String = ""
    var unitType: UnitType = .count
    var goalValue: Double = 0
    var trackingType: TrackingType = .manual
    var iconName: String = "circle.dotted"
    var motivationDescription: String = ""
    var expectedOutcomeDescription: String = ""
    var imageData: Data?
    var lifeArea: LifeArea = .health
    var type: ActivityTypes = .increase
    var secondaryNote: String?
}

#Preview {
    CreateActivityView()
        .modelContainer(for: Activity.self, inMemory: false)
}
