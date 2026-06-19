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
        VStack(alignment: .center, spacing: 10) {
            ZStack {
                ActivityImageView(path: selectedActivity?.imagePath, icon: selectedActivity?.iconName)
                    .edgesIgnoringSafeArea(.horizontal)
                
                VStack {
                    //Title
                    Text("Add your progress for")
                        .font(.title)
                        .fontWeight(.medium)
                    // Header
                    Text(selectedActivity?.name ?? "")
                        .font(.headline)
                        .padding(.bottom, 60)
                }
                .background(.white.opacity(0.2))
            }
            
            //Label
            Text(getLabel())
                .font(.headline)
                .padding()
            
            // Input field
            HStack {
                TextField("Enter value", value: $value, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .padding(7)
                    .glassEffect()
                    .frame(maxWidth: 100, alignment: .center)
                Button(action: {
                    value = 0
                }, label: {
                    Label("Cancel", systemImage: "xmark")
                        .padding(9)
                })
                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 26))
            }
            .padding()
            // Quick buttons
            HStack(spacing: 12) {
                ForEach(quickButtonsSuggestions(selectedActivity?.unitType ?? .count), id: \.self) { suggestion in
                    quickButton(suggestion)
                }
            }
                            
            HStack {
                //RETURN ACTIVITY PICK
                if !entryFromSelectedActivity {
                    Button("Select activity") {
                        self.step = .selectActivity
                    }
                    .padding(15)
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 26))
                }
                
                // Save
                Button("Save") {
                    save()
                }
                .padding()
                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 26))
            }
            .padding(.vertical, 40)
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
    func quickButton(_ amount: Double) -> some View {
        Button("+\(Int(amount))") {
            value += amount
        }
        .padding(13)
        .font(.system(size: 14, weight: .bold, design: .rounded))
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 10))
    }
    
    func getLabel() -> String {
        switch selectedActivity?.unitType {
        case .minutes:
            return "How many minutes?"
        case .steps:
            return "How many steps?"
        case .sessions:
            return "How many sessions?"
        case .count:
            return "How many?"
        case .pages:
            return "How many pages?"
        case .none:
            return "None"
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
    AddActivityProgressView(
        activity: Activity(
            name: "Meditation",
            unitType: .sessions,
            goalValue: 3,
            trackingType: .manual)
//        activity: nil
    )
    .modelContainer(for: Activity.self, inMemory: false)
    .modelContainer(for: ProgressRecord.self, inMemory: false)
}

