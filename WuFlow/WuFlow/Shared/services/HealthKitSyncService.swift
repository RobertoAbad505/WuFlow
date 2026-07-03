//
//  HealthKitSyncService.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/2/26.
//

import Foundation
import SwiftData

final class HealthKitSyncService {

    static let shared = HealthKitSyncService()

    private init() { }
    
    func sync(_ container: ModelContainer) {
        let context = ModelContext(container)
        self.syncHealthSteps(context)
        //sync any automation progress
        //sync mindfulness sessions
        //sync workouts
    }
    
    func syncHealthSteps(_ context: ModelContext) {
        HealthKitService.shared.fetchTodayStepCount { todaySteps in
            guard todaySteps > 0 else {
                print("No steps today, sync skipped")
                return
            }
            guard let activity = self.findHealtActivityByTrackingType(.healthSteps, context) else {
                print("No healt activity found for \(TrackingType.healthSteps.title)")
                return
            }
            let importedSteps = self.getTodaysStepsRecorded(activity)
            let difference = todaySteps - importedSteps
            guard difference > 0 else {
                print("✅ STEPS synchronized")
                return
            }
            Task { @MainActor in
                do {
                    
                    try ProgressRecordingService.shared.recordProgress(for: activity,
                                                                      value: difference,
                                                                      source: .healthSteps,
                                                                      context: context)
                    print("🔄 HealthKit Synchronization ─────────────────────────")
                    print("Activity:", activity.name)
                    print("Provider:", activity.trackingType.title)
                    print("HealtKit total steps:", todaySteps)
                    print("Already imported steps:", importedSteps)
                    print("Total new steps:", difference)
                    print("──────────────────────────────────────────────────────")
                } catch let error {
                    print("❌❌❌❌ Error:")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func findHealtActivityByTrackingType(_ trackingType: TrackingType, _ context: ModelContext) -> Activity? {
        let descriptor = FetchDescriptor<Activity>()
        guard let activity = try? context.fetch(descriptor).first(where: {
            $0.trackingType == trackingType
        }) else {
            return nil
        }
        return activity
    }
    
    func getTodaysStepsRecorded(_ activity: Activity) -> Double {
        let importedSteps = activity.progressRecords
            .filter {
                Calendar.current.isDateInToday($0.date)
                &&
                $0.source == .healthSteps
            }
            .reduce(0) {
                $0 + $1.value
            }
        return importedSteps
    }
    
    func resetTodayHealthStepSync(_ activity: Activity, context: ModelContext) {
        let calendar = Calendar.current

        let records = activity.progressRecords.filter {
            calendar.isDateInToday($0.date) && $0.source == .healthSteps
        }

        records.forEach {
            context.delete($0)
        }

        do {

            try context.save()
            print("✅ Today's imported HealthKit steps removed.")
        } catch {

            print(error)
        }
    }

}
