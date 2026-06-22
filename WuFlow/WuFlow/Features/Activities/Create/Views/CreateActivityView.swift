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
    
    @State private var imageIndex: Int = 1
    @State private var mode: ActivityFlowMode
    @State private var step: CreateActivityStep = .identity
    @State private var draft = ActivityDraft()
    @StateObject private var cameraManager = CameraManager()
    let allSteps: [CreateActivityStep] = [
        .identity,
        .measurement,
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
            ZStack {
                Image("backgroundCA\(imageIndex)")
                    .resizable()
                    .ignoresSafeArea()
                content
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    var content: some View {
        VStack {
            stepView
            navigationControls
        }
        .padding()
    }
    var stepView: some View {
        VStack(alignment: .center, spacing: 0) {
            closeHeader
            switch step {
            case .identity:
                IdentityStepView(draft: $draft)
            case .measurement:
                MeasurementStepView(draft: $draft)
            case .intention:
                IntentionStepView(draft: $draft)
            case .lifeArea:
                LifeAreaStepView(draft: $draft)
            case .goal:
                GoalStepView(draft: $draft)
            case .meaning:
                MeaningStepView(draft: $draft, mode)
            case .visual:
                VisualStepView(draft: $draft, cameraManager: cameraManager)
            case .review:
                ReviewStepView(draft: draft)
            }
        }
    }

    private var closeHeader: some View {
        HStack {
            Button(action: { dismiss() }, label: {
                HStack {Image(systemName: "chevron.left")}
                .font(.system(size: 15, weight: .regular))
            })
            .buttonStyle(.glass)
            Spacer()
        }
        .padding()
        .foregroundStyle(Color(.label))
    }
    private func saveActivity() {
        withAnimation {
            
            // Prefer draft.imageData (source of truth)
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
                    imagePath: draft.imagePath,
                    type: draft.type,
                    lifeArea: draft.lifeArea,
                    secondaryNote: draft.secondaryNote,
                    goalPeriod: draft.goalPeriod,
                    measurement: draft.measurement
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
                activity.imagePath = draft.imagePath
                activity.type = draft.type
                activity.lifeArea = draft.lifeArea
                activity.secondaryNote = draft.secondaryNote
                activity.measurement = draft.measurement
                activity.goalPeriod = draft.goalPeriod
            }
            
            // Save context explicitly (important for edit)
            do {
                try modelContext.save()
                print("✅ Save success")
            } catch let error {
                print("❌ Save failed:", error.localizedDescription)
            }
            // 🔥 IMPORTANT: clean camera state
            cameraManager.image = nil
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
            withAnimation {
                dismiss()
            }
        } else {
            withAnimation {
                step = nextStep()
            }
        }
    }
    var navigationControls: some View {
        HStack(alignment: .top, spacing: 0) {
            if step != .identity {
                Button(action: {
                    withAnimation {
                        step = previousStep()
                        imageIndex -= 1
                        if imageIndex == 0 {
                            imageIndex = 1
                        }
                    }
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(Font.body)
                        Text("Back")
                    }
                })
                .padding()
                .glassEffect()
            }
            Spacer()
            Button(action: {
                handleNext()
                imageIndex += 1
                if imageIndex == 5 {
                    imageIndex = 1
                }
            }, label: {
                HStack {
                    Text(step == .review ? modeTitle : "Next")
                    Image(systemName: "chevron.right")
                        .font(Font.body)
                }
            })
            .padding()
            .glassEffect()
        }
        .tint(.green)
        .padding()
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
enum ActivityFlowMode: Equatable {
    case create
    case edit(Activity)
}
enum CreateActivityStep {
    case identity
    case measurement
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
    var imagePath: String?
    var lifeArea: LifeArea = .health
    var type: ActivityTypes = .increase
    var secondaryNote: String?
    var measurementTypeRaw: String = MeasurementType.session.rawValue
    var goalPeriodRaw: String = GoalPeriod.daily.rawValue
    var defaultIncrement: Double = 1
    
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
        self.imagePath = activity.imagePath
        self.lifeArea = activity.lifeArea
        self.type = activity.type
        self.secondaryNote = activity.secondaryNote
        self.measurement = activity.measurement
        self.goalPeriod = activity.goalPeriod
    }
    
    var goalPeriod: GoalPeriod {
        get {
            GoalPeriod(
                rawValue: goalPeriodRaw
            ) ?? .daily
        }
        set {
            goalPeriodRaw = newValue.rawValue
        }
    }
    var measurement: MeasurementType {
        get {
            MeasurementType(
                rawValue: measurementTypeRaw
            ) ?? .session
        }
        set {
            measurementTypeRaw = newValue.rawValue
        }
    }
}

#Preview {
    CreateActivityView(mode: .create)
        .modelContainer(for: Activity.self, inMemory: false)
}
