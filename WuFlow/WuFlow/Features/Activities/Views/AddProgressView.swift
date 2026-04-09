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
        } else {
            _step = State(initialValue: .selectActivity)
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                AnimatedBackgroundView()
                    .ignoresSafeArea()
                VStack {
                    switch step {
                    case .selectActivity:
                        selectActivityView
                    case .inputValue:
                        inputView
                    }
                }
                .padding()
            }
        }
        .animation(.easeInOut, value: step)
        
    }
    var inputView: some View {
        VStack(alignment: .center, spacing: 10) {
            //Title
            Text("Add your progress for")
                .font(.title)
                .fontWeight(.medium)
            // Header
            HStack {
                Image(systemName: selectedActivity?.iconName ?? "circle")
                    .font(.system(size: 25))
                Text(selectedActivity?.name ?? "")
                    .font(.headline)
            }
            .padding(.bottom, 60)
            
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
                Button("Select activity") {
                    self.step = .selectActivity
                }
                .padding(15)
                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 26))
                
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
        
        let record = ProgressRecord(
            value: value,
            source: .manual,
            activity: activity
        )
        
        activity.progressRecords.append(record)
        context.insert(record)
        
        try? context.save()
        
        dismiss()
    }
    
}
enum AddProgressStep {
    case selectActivity
    case inputValue
}
struct FloatingBlob: View {
    
    @State private var move = false
    let color: Color = .purple
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.5))
            .frame(width: 250)
            .blur(radius: 80)
            .offset(x: move ? 250 : -300, y: move ? -200 : 200)
            .animation(
                .easeInOut(duration: 10)
                .repeatForever(autoreverses: true),
                value: move
            )
            .onAppear {
                move.toggle()
            }
    }
}
#Preview {
    AddActivityProgressView(
//        activity: Activity(
//            name: "Meditation",
//            unitType: .sessions,
//            goalValue: 3,
//            trackingType: .manual)
        activity: nil
    )
    .modelContainer(for: Activity.self, inMemory: false)
    .modelContainer(for: ProgressRecord.self, inMemory: false)
}

