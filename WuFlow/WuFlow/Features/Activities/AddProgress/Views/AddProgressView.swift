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
    @Environment(\.repository)
    private var repository
    
    @Query var activities: [Activity]
    
    @State private var step: AddProgressStep
    @State private var selectedActivity: Activity?
    @State private var value: Double = 0
    @State private var providedActivity: Bool = false
    
    private let entryFromSelectedActivity: Bool
    private let progressCalculator: ProgressCalculator = .init()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    func quickButtonsSuggestions(_ unit: UnitType) -> [Double] {
        switch unit {
        case .minutes:
            return [5,10,15,30,60]
        case .steps:
            return [100,200,400,600,800]
        case .sessions, .count:
            return [1,2,3,4,5]
        case .pages:
            return [5,10,20,30,40]
        }
    }
    private var progress: ProgressSummary? {
        guard let activity = selectedActivity else {
            return nil
        }

        return progressCalculator.progress(for: activity, records: activity.progressRecords)
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
    
    private var backgroundStyle: BackgroundStyle {
        guard let activity = self.selectedActivity else {
            return .wuFlow
        }
        switch activity.type {
        case .increase: return .growth
        case .maintain: return .flow
        case .decrease: return .reduce
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(style: backgroundStyle)
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
        ScrollView {
            VStack {
                switch step {
                case .selectActivity:
                    selectActivityView
                case .inputValue:
                    inputView
                }
            }
            .padding(20)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
            .background(AppColors.surface.opacity(0.94), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(AppColors.divider.opacity(0.85), lineWidth: 1)
            }
            .padding(16)
            .animation(.easeInOut, value: step)
        }
    }
    var inputView: some View {
        VStack(spacing: 24) {
            activityImageHeader
            activityHeader
            progressSummary
            inputSection
            quickActions
            actionButtons
        }
    }
    var activityImageHeader: some View {
        ActivityImageView(
            path: selectedActivity?.imagePath,
            icon: selectedActivity?.iconName
        )
        .scaledToFill()
        .frame(maxWidth: .infinity, maxHeight: 230)
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }
    private var activityHeader: some View {
        Text(selectedActivity?.name ?? "")
            .font(.title2.bold())
    }
    private var progressSummary: some View {
        VStack(spacing: 12) {
            if let activity = selectedActivity, let progress = progress {
                ProgressView(value: progress.ratio)
                    .tint(AppColors.oceanBlue)
                Text(progress.description(activity.measurement))
                    .font(.headline)

                Text(activity.goalPeriod.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    private var inputSection: some View {
        VStack(spacing: 12) {
            Text(inputTitle)
                .font(.system(.headline, design: .default, weight: .medium))
            TextField(
                "0",
                value: $value,
                format: .number
            )
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 25, weight: .bold))
            .padding(10)
            .background(AppColors.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppColors.divider, lineWidth: 1)
            }
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
            if let unit = selectedActivity?.unitType {
                ForEach(
                    quickButtonsSuggestions(unit),
                    id: \.self
                ) { amount in

                    Button {
                        value += amount
                    } label: {
                        Text("+\(Int(amount))")
                            .font(.headline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                    }
                    .foregroundStyle(AppColors.midnightNavy)
                    .background(AppColors.mistBlue.opacity(0.55), in: Capsule())
                }
            }
        }
    }
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                save()
            } label: {
                Label(title: {
                    Text(saveButtonTitle)
                }, icon: {
                    Image(systemName: "plus")
                })
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.midnightNavy)

            if !entryFromSelectedActivity {
                Button("Choose another activity") {
                    step = .selectActivity
                }
                .foregroundStyle(AppColors.oceanBlue)
            } else {
                //Cancel add progress
                Button {
                    dismiss()
                } label: {
                    Label(title: {
                        Text("Cancel")
                    }, icon: {
                        Image(systemName: "chevron.left")
                    })
                    .frame(maxWidth: .infinity)
                }
                .foregroundStyle(AppColors.midnightNavy)
                .buttonStyle(.bordered)
                .tint(AppColors.secondaryText)
            }
        }
    }
    private var saveButtonTitle: String {
        guard let activity = selectedActivity else {
            return "Save"
        }
        switch activity.measurement {
        case .session:
            return "Add Session"
        case .duration:
            return "Add \(Int(value)) Minutes"
        case .count:
            return "Add Progress"
        case .distance:
            return "Add Distance"
        }
    }
    var selectActivityView: some View {
        ActivitySelectionGridView(activities: self.activities,
                                  onSelect: { activitySelected in
            selectedActivity = activitySelected
            step = .inputValue
        })
    }
    func save() {
        guard let repository else {
            return
        }
        guard let activity = selectedActivity else {
            return
        }
        Task {
            do {
                if activity.trackingType  == .healthSteps {
                    
                    
                } else {
                    try await repository.addProgress(
                        activityId: activity.id,
                        value: value,
                        source: .manual
                    )
                }
            } catch let error {
                print("Error saving progress: \(error)")
            }
        }
        dismiss()
    }
    
}
enum AddProgressStep {
    case selectActivity
    case inputValue
}
#Preview {
    let path = try? ImageStore.shared.save(UIImage(named: "selfie") ?? UIImage(),
                                           category: .activity)
    // Seed initial data into an in-memory model container so @Query works in previews
    let previewItems = [
        Activity(name: "GYM", unitType: .count, goalValue: 20, trackingType: .manual, imagePath: path),
        Activity(name: "Meditation", unitType: .count, goalValue: 20, trackingType: .manual, imagePath: path),
        Activity(name: "Push-ups", unitType: .count, goalValue: 20, trackingType: .manual, imagePath: path)
    ]
    AddActivityProgressView(
        activity: Activity(
            name: "Meditation",
            unitType: .sessions,
            goalValue: 3,
            trackingType: .manual,
            imagePath: path)
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

