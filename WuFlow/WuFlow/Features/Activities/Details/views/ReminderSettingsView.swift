//
//  ReminderSettingsView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/3/26.
//
import SwiftData
import SwiftUI

struct ReminderSettingsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    let activity: Activity
    
    @State var selectedPreset: ReminderPreset = .morning
    @State var selectedTime: Date
    
    init(activity: Activity) {
        
        self.activity = activity
        
        _selectedPreset = State(
            initialValue: activity.reminderPreset
        )
        
        _selectedTime = State(
            initialValue: activity.reminderTime ?? Date()
        )
    }
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(style: .energy)
            content
        }
    }
    
    var content: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(alignment: .center) {
                Image(systemName: "bell.fill")
                    .font(Font.title2.monospacedDigit())
                    .symbolEffect(.wiggle.byLayer)
                Text("Gentle Support")
                    .font(.title)
                    .fontWeight(.bold)
            }
            VStack {
                Text("Reminders can help your activity become part of your natural flow.")
                    .font(Font.body.monospacedDigit())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: .infinity)
                    
                
                Text("When would support feel most helpful?")
                    .font(Font.body.monospacedDigit())
            }
            .padding()
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(.white, lineWidth: 3)
            }
            
            HStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)) {
                    ForEach(ReminderPreset.allCases, id: \.self) { reminderPreset in
                        HStack {
                            Text(reminderPreset.rawValue)
                                .font(Font.body.monospacedDigit())
                        }
                        .padding(30)
                        .background(.green.opacity(selectedPreset == reminderPreset ? 0.1 : 0))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedPreset == reminderPreset ? .green : .clear, lineWidth: 2)
                        }
                        .onTapGesture {
                            selectedPreset = reminderPreset
                        }
                    }
                }
            }
            if selectedPreset == .custom {
                withAnimation(.spring) {
                    VStack {
                        Text("Choose your reminder time: ")
                        DatePicker(
                            "",
                            selection: $selectedTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            
            Button(action: {
                withAnimation {
                    save()
                    dismiss()
                }
            }, label: {
                HStack {
                    Image(systemName: "arrow.up.circle.badge.clock")
                    Text("Get support!")
                }
            })
            .frame(maxWidth: .infinity)
            .padding(10)
            .glassEffect()
            Button(action: {
                withAnimation {
                    dismiss()
                }
            }, label: {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text("Cancel")
                }
            })
            .frame(maxWidth: .infinity)
            .padding(10)
            .glassEffect()
        }
        .padding()
    }
    func save() {

        activity.reminderPreset = selectedPreset

        if selectedPreset == .custom {
            activity.reminderTime = selectedTime
        } else {
            activity.reminderTime = nil
        }

        guard let modelContext = activity.modelContext else {
            print("❌ Missing model context")
            return
        }

        do {

            try modelContext.save()

            if activity.remindersEnabled {
                NotificationManager.shared.scheduleReminder(for: activity)
            } else {
                NotificationManager.shared.cancelReminder(for: activity)
            }

            print("✅ Reminder configuration saved")

        } catch {
            print("❌ Error saving reminder: \(error)")
        }
    }
}

#Preview {
    let activity = Activity(
        name: "Meditation",
        unitType: .sessions,
        goalValue: 3,
        trackingType: .manual,
        remindersEnabled: true
//        ,
//        reminderType: ReminderType.scheduled
    )
    ReminderSettingsView(activity: activity)
        .modelContainer(for: Activity.self, inMemory: false)
        .modelContainer(for: ProgressRecord.self, inMemory: false)
}
