//
//  AddProgressView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import SwiftUI
import SwiftData

struct AddActivityProgressView: View {
    
    @Environment(\.modelContext) var context
    
    let activity: Activity
    @State var newProgresValue: Double = 0
    var onDismiss: (() -> Void)
    
    init(activity: Activity, onDismiss: @escaping (() -> Void)) {
        self.activity = activity
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Add new progress")
                .font(.title)
            
            
            Text(getLabel())
                .font(.title)
            
            TextField(getLabel(), value: $newProgresValue, formatter: NumberFormatter())
                .font(.headline)
                .padding(.bottom, 70)
            
            Button(action: saveProgress, label: {
                Text("Save progress!")
                    .padding(.horizontal)
            })
            .buttonStyle(.borderedProminent)
        }
        .padding(25)
    }
    
    func saveProgress() {
        let newProgress = ProgressRecord(
            value: newProgresValue,
            source: .manual,
            activity: activity
        )
        print(newProgress)
        activity.progressRecords.append(newProgress) // 🔥 important
        context.insert(newProgress)
        do {
            try context.save()
        } catch let error {
            print("❌❌❌ Error at saving progress!")
            print(error.localizedDescription)
        }
        onDismiss()
    }
    
    func getLabel() -> String {
        switch activity.unitType {
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
        }
    }
}

#Preview {
    AddActivityProgressView(
        activity: Activity(
            name: "Meditation",
            unitType: .sessions,
            goalValue: 3,
            trackingType: .manual),
        onDismiss: {})
        .modelContainer(for: Activity.self, inMemory: true)
        .modelContainer(for: ProgressRecord.self, inMemory: true)
}

