//
//  HealtKitSettingsView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/9/26.
//

import SwiftUI

struct HealtKitSettingsView: View {
    @State private var mindfulSessions: [MindfulnessSessionSummary] = []
    @State private var stepCount: Double = 0.0
    @AppStorage("healtKitEnabled")
    
    private var healtKitEnabled: Bool = false
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(style: .calm)
            content
        }
    }
    var content: some View {
        VStack(alignment: .leading, spacing: 30) {
            titleHeader
            stepCountSection
            workoutsInfo
            mindfulnessSection
            requestPermissionButton
        }
        .padding()
    }
    var workoutsInfo: some View {
        Button("Read Recent Workouts") {
            HealthKitService.shared
                .fetchRecentWorkouts { workouts in

                    print("🏋️ Workouts:")

                    for workout in workouts {

                        print(
                            workout.workoutType,
                            workout.durationMinutes,
                            workout.startDate
                        )
                    }
                }
        }
    }
    var stepCountSection: some View {
        VStack {
            HStack {
                Image(systemName: "figure.walk")
                    .font(.title)
                Text(stepCount.formatted())
                    .font(.largeTitle.bold())
            }
            Text("Steps")
                .font(Font.body.weight(.bold))
            Button(action: {
                HealthKitService.shared.fetchTodayStepCount(completion: { steps in
                    DispatchQueue.main.async {
                        print("🚶 Today's Steps:", steps)
                        self.stepCount = steps
                    }
                })
            }, label: {
              Text("Refresh")
                    .padding(5)
            })
            .buttonStyle(.glass)
        }
        .padding(.vertical)
    }
    var mindfulnessSection: some View {
        VStack {
            HStack {
                Image(systemName: "brain")
                    .font(.title)
                Text("\(mindfulSessions.count)")
                    .font(.largeTitle.bold())
            }
            Text("Mindfulness Sessions")
                .font(Font.body.weight(.bold))
            Button(action: {
                HealthKitService.shared.fetchRecentMindfulnessSessions(completion: { data in
                    print("🧠 MindfulnessSessions:")
                    for session in data {
                        print(
                            session.durationMinutes,
                            session.endDate,
                            session.startDate
                        )
                    }
                    self.mindfulSessions = data
                })
            }, label: {
              Text("Refresh mindfulness sessions")
                    .padding(5)
            })
            .buttonStyle(.glass)
        }
        .padding(.vertical)
    }
    var titleHeader: some View {
        HStack {
            Image(systemName: "figure.cooldown")
                .font(Font.largeTitle.weight(.bold))
            Text("HealtKit Settings")
                .font(Font.largeTitle.weight(.bold))
        }
    }
    var requestPermissionButton: some View {
        HStack {
            Button("Request HealthKit Access") {
                HealthKitService.shared
                    .requestAuthorization { granted in
                        healtKitEnabled = granted
                        print("Granted:", granted)
                    }
            }
            .buttonStyle(.glass)
            Button("Create Test Mindfulness Session") {
                HealthKitService.shared
                    .createTestMindfulnessSession()
            }
            .buttonStyle(.glass)
        }
    }
}

#Preview {
    HealtKitSettingsView()
}
