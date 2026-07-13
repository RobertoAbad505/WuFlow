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
        self.syncHealthSteps()
        //sync any automation progress
        //sync mindfulness sessions
        //sync workouts
    }
    
    func syncHealthSteps() {
        HealthKitService.shared.fetchTodayStepCount { todaySteps in
            Task {
                do {
                    try await self.repository.syncHealthSteps(totalSteps: todaySteps)
                }  catch let error {
                    print("❌❌❌❌ Error:")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func resetTodayHealthStepSync(_ activityId: UUID) {
        Task {
            guard let activity = try await repository.activity(id: activityId) else {
                return
            }
            
            do {
                try await self.repository.resetTodayHealthStepSync(activity)
                print("✅ Today's imported HealthKit steps removed.")
            } catch {
                print(error)
            }
        }
    }
}
