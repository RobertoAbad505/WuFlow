//
//  AddProgressView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import SwiftUI
import SwiftData

struct AddActivityProgressView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @Query var activities: [Activity]
    
    @State private var step: AddProgressStep
    @State private var selectedActivity: Activity?
    @State private var value: Double = 0
    @State private var providedActivity: Bool = false
    
    private let entryFromSelectedActivity: Bool
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    func quickButtonsSuggestions(_ unit: UnitType) -> [Double] {
        switch unit {
        case .minutes:
            return [10,15,30,45,60]
        case .steps:
            return [100,200,400,600,800]
        case .sessions, .count:
            return [1,2,3,4,5]
        case .pages:
            return [5,10,20,30,40]
        }
    }
    
    init(activity: Activity? = nil) {
        if let activity {
            _step = State(initialValue: .inputValue)
            _selectedActivity = State(initialValue: activity)
            entryFromSelectedActivity = true
        } else {
            _step = State(initialValue: .selectActivity)
            entryFromSelectedActivity = false
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(style: .wuFlow)
                .ignoresSafeArea()
            content
        }
        .onAppear {
            if value == 0 {
                value = selectedActivity?.defaultIncrement ?? 0
            }
        }
    }
    
    var content: some View {
        VStack {
            switch step {
            case .selectActivity:
                selectActivityView
            case .inputValue:
                inputView
            }
        }
        .padding()
        .animation(.easeInOut, value: step)
    }
    var inputView: some View {

        ScrollView {

            VStack(spacing: 24) {

                activityHeader

                progressSummary

                inputSection

                quickActions

                actionButtons
            }
            .padding()
        }
    }
    private var activityHeader: some View {

        VStack(spacing: 12) {
            ActivityImageView(
                path: selectedActivity?.imagePath,
                icon: selectedActivity?.iconName
            )
            .frame(height: 160)

            Text(selectedActivity?.name ?? "")
                .font(.title2.bold())

            if let activity = selectedActivity {

                Text(activity.goalDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    private var progressSummary: some View {

        VStack(spacing: 12) {

            if let activity = selectedActivity {

                ProgressView(
                    value: activity.progressRatio
                )

                Text(activity.progressDescription)
                    .font(.headline)

                Text(activity.periodDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    private var inputSection: some View {

        VStack(spacing: 12) {

            Text(inputTitle)
                .font(.headline)

            TextField(
                "0",
                value: $value,
                format: .number
            )
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 42, weight: .bold))
            .padding()
            .glassEffect()
        }
    }
    private var inputTitle: String {

        guard let activity = selectedActivity else {
            return "Add Progress"
        }

        switch activity.measurement {

        case .session:
            return "How many sessions?"

        case .duration:
            return "How many minutes?"

        case .count:
            return "How much progress?"

        case .distance:
            return "How many kilometers?"
        }
    }
    private var quickActions: some View {

        HStack(spacing: 12) {

            ForEach(
                suggestedValues,
                id: \.self
            ) { amount in

                Button {

                    value += amount

                } label: {

                    Text("+\(Int(amount))")
                        .font(.headline)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                }
                .glassEffect(
                    .clear,
                    in: Capsule()
                )
            }
        }
    }
    private var suggestedValues: [Double] {

        guard let activity = selectedActivity else {
            return []
        }

        switch activity.measurement {

        case .session:
            return [1]

        case .duration:
            return [5, 10, 15, 30]

        case .count:
            return [100, 500, 1000, 5000]

        case .distance:
            return [1, 2, 5, 10]
        }
    }
    private var actionButtons: some View {

        VStack(spacing: 12) {

            Button {

                save()

            } label: {

                Text(saveButtonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if !entryFromSelectedActivity {

                Button("Choose Another Activity") {

                    step = .selectActivity
                }
            }
        }
    }
    private var saveButtonTitle: String {

        guard let activity = selectedActivity else {
            return "Save"
        }

        switch activity.measurement {

        case .session:
            return "Complete Session"

        case .duration:
            return "Add \(Int(value)) Minutes"

        case .count:
            return "Add Progress"

        case .distance:
            return "Add Distance"
        }
    }
    var selectActivityView: some View {
        VStack(alignment: .center, spacing: 24) {
            ActivitySelectionGridView(activities: self.activities,
                                      onSelect: { activitySelected in
                selectedActivity = activitySelected
                step = .inputValue
            })
        }
    }
    func save() {
        guard let activity = selectedActivity else { return }
        
        
        do {
            try ProgressRecordingService.shared.recordProgress(for: activity,
                                                           value: value,
                                                           source: activity.trackingType,
                                                           context: context)
        } catch let error {
            print("Error saving progress: \(error)")
        }
        dismiss()
    }
    
}
enum AddProgressStep {
    case selectActivity
    case inputValue
}
#Preview {
    // Seed initial data into an in-memory model container so @Query works in previews
    let previewItems = [
        Activity(name: "GYM", unitType: .count, goalValue: 20, trackingType: .manual),
        Activity(name: "Meditation", unitType: .count, goalValue: 20, trackingType: .manual),
        Activity(name: "Push-ups", unitType: .count, goalValue: 20, trackingType: .manual)
    ]
    AddActivityProgressView(
        activity: Activity(
            name: "Meditation",
            unitType: .sessions,
            goalValue: 3,
            trackingType: .manual)
//        activity: nil
    )
    .modelContainer(for: Activity.self, inMemory: true) { result in
        if case let .success(container) = result {
            let context = container.mainContext
            previewItems.forEach { context.insert($0) }
            try? context.save()
        }
    }
    .modelContainer(for: ProgressRecord.self, inMemory: false)
}

