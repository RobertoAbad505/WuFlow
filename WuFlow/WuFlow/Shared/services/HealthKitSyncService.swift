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
    
    private(set) var isSyncing = false
    private(set) var completedDays = 0
    private(set) var totalDays = 0
    private(set) var currentDay: Date?
    private(set) var errors: [String] = []

    var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(completedDays) / Double(totalDays)
    }
    
    init(repository: ActivityRepository) {
        self.repository = repository
    }

    /// Synchronizes today and yesterday to recover missed daily imports.
    func sync() {
        Task {
            await syncRecentDays()
        }
    }

    /// Synchronizes today and the previous calendar day.
    func syncRecentDays(
        endingAt date: Date = .now,
        calendar: Calendar = .current
    ) async {
        let today = calendar.startOfDay(for: date)

        guard let yesterday = calendar.date(
            byAdding: .day,
            value: -1,
            to: today
        ) else {
            await syncHealthSteps(for: today)
            return
        }
        // Sync sequentially to avoid concurrent writes to the repository.
        await syncHealthSteps(for: yesterday)
        await syncHealthSteps(for: today)
    }

    /// Synchronizes the steps for one specific calendar day.
    func syncHealthSteps(for day: Date) async {
        do {
            let totalSteps = try await HealthKitService.shared
                .stepCount(for: day)

            try await repository.syncHealthSteps(
                totalSteps: totalSteps,
                day: day
            )
        } catch {
            print("HealthKit sync failed for \(day):", error)
        }
    }
    
    func sync(
        days: [Date],
        calendar: Calendar = .current
    ) async {
        
        guard !isSyncing else { return }

        isSyncing = true
        completedDays = 0
        totalDays = days.count
        errors = []

        defer {
            isSyncing = false
            currentDay = nil
        }

        for day in days {
            if Task.isCancelled {
                break
            }

            let normalizedDay = calendar.startOfDay(for: day)
            currentDay = normalizedDay

            do {
                let totalSteps = try await HealthKitService.shared
                    .stepCount(for: normalizedDay)

                try await repository.syncHealthSteps(
                    totalSteps: totalSteps,
                    day: normalizedDay
                )
            } catch {
                errors.append(
                    "\(normalizedDay.formatted(date: .abbreviated, time: .omitted)): \(error.localizedDescription)"
                )
            }

            completedDays += 1
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
