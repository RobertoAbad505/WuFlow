//
//  HealthKitSyncService.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/2/26.
//

import Foundation
import SwiftData
import Observation

@Observable
final class HealthKitSyncService {
    
    private let repository: ActivityRepository
    
    init(repository: ActivityRepository) {
        self.repository = repository
    }
    
    func sync() {
        Task {
             await self.syncHealthSteps(for: Date.now)
        }
    }
    
    
    
    func syncHealthSteps(for day: Date) async {
        //sync any automation progress
        //sync mindfulness sessions
        //sync workouts
        do {
            let totalSteps = try await HealthKitService.shared.stepCount(for: day)
            
            try await repository.syncHealthSteps(
                totalSteps: totalSteps,
                day: day
            )
        } catch {
            print(error)
        }
    }
    
    func resetTodayHealthStepSync(_ activityId: UUID) {
        Task {
            guard let activity = try await repository.activity(id: activityId) else {
                return
            }
            
            do {
                let calendar = Calendar.current
                for record in activity.progressRecords {

                    print(record.date)
                    print(calendar.isDateInToday(record.date))
                }
                try await self.repository.resetTodayHealthStepSync(activity)
                print("✅ Today's imported HealthKit steps removed.")
            } catch {
                print(error)
            }
        }
    }
}

struct HealthMetricValue {
    let metric: HealthMetric
    let day: Date
    let value: Double
}
enum HealthMetric {
    case steps
    case walkingDistance
    case activeEnergy
    case exerciseMinutes
}
enum HealthKitError: Error {
    case unavailable
    case invalidDate
    case quantityTypeUnavailable
}
