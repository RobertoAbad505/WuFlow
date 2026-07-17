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
    @Environment(\.repository) private var repository
    
    @State private var imageIndex: Int = 1
    @State private var mode: ActivityFlowMode
    @State private var step: CreateActivityStep = .identity
    @State private var draft = ActivityDraft()
    @StateObject private var cameraManager = CameraManager()
//    let allSteps: [CreateActivityStep] = [
//        .identity,
//        .measurement,
//        .trackingType,
//        .intention,
//        .lifeArea,
//        .goal,
//        .meaning,
//        .visual,
//        .review
//    ]
    var steps: [CreateActivityStep] {
        ActivityFlow.steps(for: draft.trackingType)
    }
    
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
            case .trackingType:
                TrackingStepView(draft: $draft)
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
            case .place:
                LocationConfigurationView(draft: $draft)
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
        Task {
            guard let repository else {
                return
            }
            do {
                switch mode {
                case .create:
                    try await repository.createActivity(from: draft)
                case .edit(let activity):
                    try await repository.updateActivity(
                        id: activity.id,
                        from: draft
                    )
                }
                // 🔥 IMPORTANT: clean camera state
                cameraManager.image = nil
            }
            catch let error {
                print("Error on \(mode == .create ? "create" : "update") activity \(draft.name)")
                print(error)
                print(error.localizedDescription)
            }
        }
    }    
    func nextStep() -> CreateActivityStep {
        let steps = steps
        guard let index = steps.firstIndex(of: step),
              index < steps.count - 1 else {
            return step
        }
        return steps[index + 1]
    }

    func previousStep() -> CreateActivityStep {
        let steps = steps
        guard let index = steps.firstIndex(of: step),
              index > 0 else {
            return step
        }
        return steps[index - 1]
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
    case trackingType
    case intention
    case lifeArea
    case goal
    case meaning
    case visual
    case review
    case place
}
struct ActivityDraft {
    var id: UUID?
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
    var placeID: Place.ID?
    
    init() {
        
    }
    
    init(from activity: Activity) {
        self.id = activity.id
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
        self.measurementTypeRaw = activity.measurement.rawValue
        self.goalPeriodRaw = activity.goalPeriod.rawValue
        self.placeID = activity.place?.persistentModelID
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
struct ActivityFlow {

    static func steps(for trackingType: TrackingType) -> [CreateActivityStep] {

        switch trackingType {

        case .manual:
            return [
                .identity,
                .measurement,
                .trackingType,
                .intention,
                .lifeArea,
                .goal,
                .meaning,
                .visual,
                .review
            ]

        case .location:
            return [
                .identity,
                .measurement,
                .trackingType,
                .place,
                .intention,
                .lifeArea,
                .goal,
                .meaning,
                .visual,
                .review
            ]

        case .healthSteps:
            // Future: simplify this flow once HealthKit configuration is implemented.
            return defaultSteps

        case .healthWorkout:
            // Future: replace Measurement with workout-specific configuration.
            return defaultSteps

        case .reminder:
            // Future: insert Reminder Configuration step.
            return defaultSteps
        }
    }

    static let defaultSteps: [CreateActivityStep] = [
        .identity,
        .measurement,
        .trackingType,
        .intention,
        .lifeArea,
        .goal,
        .meaning,
        .visual,
        .review
    ]
}

#Preview {
    CreateActivityView(mode: .create)
        .modelContainer(for: Activity.self, inMemory: false)
}
