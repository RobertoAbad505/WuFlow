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
    
    private var backgroundStyle: BackgroundStyle {
        switch activity.type {
        case .increase: return .growth
        case .maintain: return .flow
        case .decrease: return .reduce
        }
    }
    
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
            AnimatedBackgroundView(style: backgroundStyle)
            content
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Image(systemName: "bell.fill")
                    .font(Font.title2.monospacedDigit())
                    .symbolEffect(.wiggle.byLayer)
                Text("Gentle Support")
                    .font(.title3)
                    .fontWeight(.medium)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 20) {
                Text("Reminders can help your activity become part of your natural flow.")
                    .font(Font.body)
                Text("When would support feel most helpful?")
                    .font(Font.body)
            }
            HStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)) {
                    ForEach(ReminderPreset.allCases, id: \.self) { reminderPreset in
                        HStack {
                            Text(reminderPreset.rawValue)
                                .font(Font.body.monospacedDigit())
                        }
                        .padding(25)
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
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .tint(AppColors.midnightNavy)
            Button(action: {
                withAnimation {
                    dismiss()
                }
            }, label: {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text("Cancel")
                }
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
            })
            .buttonStyle(.bordered)
            .tint(AppColors.secondaryText)
        }
        .padding()
        .padding(.horizontal)
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
                NotificationManager.shared.syncReminders(for: [activity])
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
