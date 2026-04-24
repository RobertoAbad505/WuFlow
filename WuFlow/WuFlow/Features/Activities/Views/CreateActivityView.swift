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
    
    @State private var mode: ActivityFlowMode
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
    
    init(mode: ActivityFlowMode) {
        self.mode = mode
        
        switch mode {
        case .create:
            _draft = State(initialValue: ActivityDraft())
            
        case .edit(let activity):
            _draft = State(initialValue: ActivityDraft(from: activity))
        }
    }
    
       
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
            
            // Prefer draft.imageData (source of truth)
            let imageData = draft.imageData
            
            switch mode {
                
            case .create:
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
                
                
            case .edit(let activity):
                activity.name = draft.name
                activity.unitType = draft.unitType
                activity.goalValue = draft.goalValue
                activity.trackingType = draft.trackingType
                activity.iconName = draft.iconName
                activity.motivationDescription = draft.motivationDescription
                activity.expectedOutcomeDescription = draft.expectedOutcomeDescription
                activity.imageData = imageData
                activity.type = draft.type
                activity.lifeArea = draft.lifeArea
                activity.secondaryNote = draft.secondaryNote
            }
            
            // Save context explicitly (important for edit)
            do {
                try modelContext.save()
            } catch {
                print("❌ Error saving activity: \(error.localizedDescription)")
            }
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
            Button(step == .review ? modeTitle : "Next") {
                handleNext()
            }
        }
        .padding(.horizontal)
        .font(.body)
    }
    var modeTitle: String {
        switch mode {
        case .create:
            return "Create"
        case .edit:
            return "Save"
        }
    }
    
}
enum ActivityFlowMode {
    case create
    case edit(Activity)
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
    
    init() {
        
    }
    
    init(from activity: Activity) {
        self.name = activity.name
        self.unitType = activity.unitType
        self.goalValue = activity.goalValue
        self.trackingType = activity.trackingType
        self.iconName = activity.iconName ?? "circle.dotted"
        self.motivationDescription = activity.motivationDescription ?? ""
        self.expectedOutcomeDescription = activity.expectedOutcomeDescription ?? ""
        self.imageData = activity.imageData
        self.lifeArea = activity.lifeArea
        self.type = activity.type
        self.secondaryNote = activity.secondaryNote
    }
}

#Preview {
    CreateActivityView(mode: .create)
        .modelContainer(for: Activity.self, inMemory: false)
}
