//
//  ActivityRepository.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/3/26.
//
import Foundation
import SwiftData

@ModelActor
actor ActivityRepository {
    
    func activity(id: UUID) throws -> Activity? {
        let descriptor = FetchDescriptor<Activity>(
            predicate: #Predicate {
                $0.id == id
            }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func syncHealthSteps(totalSteps: Double) throws {
        guard totalSteps > 0 else {
            print("No steps today, sync skipped")
            return
        }
        
        guard let activity = try automatedActivity(trackingType: .healthSteps) else {
            print("No healt activity found for \(TrackingType.healthSteps.title)")
            return
        }
        let imported = importedSteps(activity)
        let difference = totalSteps - imported
        guard difference > 0 else {
            print("✅ STEPS synchronized")
            return
        }
        try addProgress(
            activity: activity,
            value: difference,
            source: .healthSteps
        )
        print("🔄 HealthKit Synchronization ─────────────────────────")
        print("Activity:", activity.name)
        print("Provider:", activity.trackingType.rawValue)
        print("HealthKit total steps:", totalSteps)
        print("Already imported steps:", imported)
        print("Total new steps:", difference)

    }
    func addProgress(
        activityId: UUID,
        value: Double,
        source: TrackingType
    ) throws {
        guard let activity = try activity(id: activityId) else {
            return
        }
        try addProgress(
            activity: activity,
            value: value,
            source: source
        )
    }

    private func addProgress(activity: Activity, value: Double, source: TrackingType) throws {
        let record = ProgressRecord(
            value: value,
            source: source,
            activity: activity
        )
        modelContext.insert(record)
        try modelContext.save()
    }
    
    func automatedActivity(trackingType: TrackingType) throws -> Activity? {
        let type = trackingType.rawValue
        let descriptor = FetchDescriptor<Activity>(
            predicate: #Predicate<Activity> {
                $0.trackingTypeRaw == type
            }
        )
        do {
            return try modelContext.fetch(descriptor).first
        } catch let error {
            throw error
        }
    }
    
    func importedSteps(_ activity: Activity) -> Double {
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
    
    func resetTodayHealthStepSync(_ activity: Activity) throws {
        let calendar = Calendar.current

        let records = activity.progressRecords.filter {
            calendar.isDateInToday($0.date) && $0.source == .healthSteps
        }

        records.forEach {
            modelContext.delete($0)
        }
        try modelContext.save()
        print("✅ Today's imported HealthKit steps removed. Total affected: \(records.count)")
    }
    func completeReminder(activityId: UUID) throws -> Activity? {
        guard let activity = try activity(id: activityId) else {
            return nil
        }

        guard try !hasRecentReminderProgress(activity: activity) else {
            print("⚠️ Duplicate prevented")
            return nil
        }
        do {
            try addProgress(
                activity: activity,
                value: activity.defaultIncrement,
                source: .reminder
            )
            return activity
        } catch let error {
            throw error
        }
    }
    func hasRecentReminderProgress(activity: Activity) throws -> Bool {
        // Duplicate protection
        let fiveMinutesAgo = Date().addingTimeInterval(-300)

        let progressDescriptor = FetchDescriptor<ProgressRecord>()

        let progressRecords = try modelContext.fetch(progressDescriptor)
        
        let recentRecord = activity.progressRecords.first { record in
            record.date >= fiveMinutesAgo
        }
        if recentRecord != nil {
            return false
        }
        return true
    }
}
