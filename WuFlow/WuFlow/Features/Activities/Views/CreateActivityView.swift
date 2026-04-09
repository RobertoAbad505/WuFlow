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
    
    
    //new activity properties
    @State private var name: String = ""
    @State private var newUnitType: UnitType = .count
    @State private var newGoalValue: Double = 0
    @State private var newTrackingType: TrackingType = .manual
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            Text("Create activity")
                .font(Font.largeTitle.bold())
                .padding(.bottom, 20)
            
            //Name input
            TextField("Name", text: $name, prompt: Text("Activity name?"))
                .textContentType(UITextContentType.name)
                .font(Font.body.bold())
            
            //Unit type input
            Picker("Unit type", selection: $newUnitType) {
                ForEach(UnitType.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            .pickerStyle(.palette)
            
            //Goal input
            TextField("Goal value", value: $newGoalValue, formatter: NumberFormatter(), prompt: Text("Goal value?"))
                .textContentType(UITextContentType.name)
                .font(Font.body.bold())
            
            //Tracking type input
            Picker("Tracking type", selection: $newTrackingType) {
                ForEach(TrackingType.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
            .pickerStyle(.palette)
            
            Button("Create") {
                addItem()
                dismiss()
            }
            .padding(.top, 50)
        }
        .padding()
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Activity(name: $name.wrappedValue,
                                   unitType: $newUnitType.wrappedValue,
                                   goalValue: $newGoalValue.wrappedValue,
                                   trackingType: $newTrackingType.wrappedValue)
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    CreateActivityView()
        .modelContainer(for: Activity.self, inMemory: false)
}
