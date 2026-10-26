//
//  HealtKitSettingsView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/9/26.
//

import SwiftUI

struct HealtKitSettingsView: View {
    @State private var workoutSessions: [WorkoutSummary] = []
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
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                titleHeader
                firstRow
                requestPermissionButton
                automationTools
            }
            .padding()
        }
    }
    var titleHeader: some View {
        HStack(alignment: .top) {
            Image(systemName: "figure.cooldown")
                .font(Font.title)
            Text("HealtKit Settings")
                .font(Font.title2.weight(.bold))
        }
    }
    var firstRow: some View {
        HStack(alignment: .top) {
            stepCountSection
            mindfulnessSection
            workoutsInfo
        }
        .frame(maxWidth: .infinity)
    }
    var stepCountSection: some View {
        VStack {
            HStack {
                Image(systemName: "figure.walk")
                    .font(.title)
                Text(stepCount.formatted())
                    .font(.title.bold())
            }
            Text("Today's\nSteps")
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
    }
    var mindfulnessSection: some View {
        VStack {
            HStack {
                Image(systemName: "brain")
                    .font(.title)
                Text("\(mindfulSessions.count)")
                    .font(.title.bold())
            }
            Text("Mindfulness\nSessions")
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
              Text("Refresh")
                    .padding(5)
            })
            .buttonStyle(.glass)
        }
    }
    var workoutsInfo: some View {
        VStack {
            HStack {
                Image(systemName: "figure.run")
                    .font(.title)
                Text("\(workoutSessions.count)")
                    .font(.title.bold())
            }
            Text("Workout\n Sessions")
                .font(Font.body.weight(.bold))
            Button(action: {
                HealthKitService.shared
                    .fetchRecentWorkouts { workouts in
                        print("🏋️ Workouts:")
                        self.workoutSessions = workouts
                        for workout in workouts {
                            print("Type: \(workout.workoutType)")
                            print("Start date: \(workout.startDate)")
                            print("Duration minutes: \(workout.durationMinutes)")
                        }
                    }
            }, label: {
              Text("Refresh")
                    .padding(5)
            })
            .buttonStyle(.glass)
        }
    }
    
    var requestPermissionButton: some View {
        VStack(alignment: .leading) {
            Text("Request HealthKit Access")
                .bold(true)
            Button("HealtKit permission") {
                HealthKitService.shared
                    .requestAuthorization { granted in
                        healtKitEnabled = granted
                        print("Granted:", granted)
                    }
            }
            .background(healtKitEnabled ? .green : .red)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(maxWidth: .infinity)
            .buttonStyle(.glass)
            .padding(.bottom, 30)
            Text("Request HealthKit Access")
                .bold(true)
            Button("Create Test Mindfulness Session") {
                HealthKitService.shared
                    .createTestMindfulnessSession()
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.glass)
        }
        .padding(.horizontal)
    }
    var automationTools: some View {
        VStack {
            automationToolsTitle
            syncPreviousHealtStepsSection
        }
    }
    var automationToolsTitle: some View {
        HStack(alignment: .top) {
            Image(systemName: "wrench.and.screwdriver")
                .font(Font.title2)
            Text("Automation tools")
                .font(Font.title2.weight(.bold))
        }
    }
    
    var syncPreviousHealtStepsSection: some View {
        VStack {
            NavigationLink {
                HealthKitSyncConsoleView()
            } label: {
                Label("HealthKit Sync", systemImage: "heart.text.square")
            }
        }
    }
}

#Preview {
    HealtKitSettingsView()
}
