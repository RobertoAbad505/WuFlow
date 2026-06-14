//
//  HealthKitService.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/9/26.
//


import Foundation
import HealthKit

final class HealthKitService {

    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()
    
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {

        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let stepCount = HKQuantityType.quantityType(
            forIdentifier: .stepCount
        )!

        let mindfulness = HKCategoryType.categoryType(
            forIdentifier: .mindfulSession
        )!

        let workoutType = HKObjectType.workoutType()

        let readTypes: Set<HKObjectType> = [
            stepCount,
            mindfulness,
            workoutType
        ]
        let shareTypes: Set<HKSampleType> = [
            mindfulness
        ]

        healthStore.requestAuthorization(
            toShare: shareTypes,
            read: readTypes
        ) { success, error in

            if let error {
                print("❌ HealthKit authorization error:")
                print(error.localizedDescription)
            }

            print("HealthKit success:", success)

            completion(success)
        }
    }
    func fetchTodayStepCount(
        completion: @escaping (Double) -> Void
    ) {
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay,
                                                    end: Date(),
                                                    options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            
            if let error {
                print("❌ Step query failed:")
                print(error.localizedDescription)
                
                completion(0)
                return
            }
            
            let steps = result?
                .sumQuantity()?
                .doubleValue(
                    for: HKUnit.count()
                ) ?? 0
            
            completion(steps)
        }
        
        healthStore.execute(query)
    }
    func fetchRecentWorkouts(
        limit: Int = 10,
        completion: @escaping ([WorkoutSummary]) -> Void
    ) {

        let workoutType = HKObjectType.workoutType()

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: nil,
            limit: limit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in

            if let error {
                print("❌ Workout query failed:")
                print(error.localizedDescription)

                completion([])
                return
            }

            guard let workouts = samples as? [HKWorkout] else {
                completion([])
                return
            }

            let result = workouts.map { workout in

                WorkoutSummary(
                    workoutType: self.workoutName(
                        workout.workoutActivityType
                    ),
                    durationMinutes: workout.duration / 60,
                    startDate: workout.startDate
                )
            }

            completion(result)
        }

        healthStore.execute(query)
    }
    private func workoutName(
        _ type: HKWorkoutActivityType
    ) -> String {

        switch type {

        case .traditionalStrengthTraining:
            return "Strength Training"

        case .running:
            return "Running"

        case .walking:
            return "Walking"

        case .cycling:
            return "Cycling"

        case .yoga:
            return "Yoga"

        case .mindAndBody:
            return "Mind & Body"

        default:
            return "Other"
        }
    }
    func fetchRecentMindfulnessSessions(limit: Int = 10, completion: @escaping ([MindfulnessSessionSummary]) -> Void) {
        guard let mindfulnessType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            completion([])
            return
        }
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )

        let query = HKSampleQuery(
            sampleType: mindfulnessType,
            predicate: nil,
            limit: limit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in

            if let error {
                print("❌ Workout query failed:")
                print(error.localizedDescription)

                completion([])
                return
            }

            guard let sessions =
                samples as? [HKCategorySample] else {

                completion([])
                return
            }

            let result = sessions.map { sample in

                MindfulnessSessionSummary(
                    startDate: sample.startDate,
                    endDate: sample.endDate
                )
            }

            completion(result)
        }

        healthStore.execute(query)
    }
    
    //TESTING FUNCTIONS
    func createTestMindfulnessSession() {

        guard let mindfulnessType =
            HKCategoryType.categoryType(
                forIdentifier: .mindfulSession
            ) else {

            return
        }

        let endDate = Date()

        let startDate = Calendar.current.date(
            byAdding: .minute,
            value: -10,
            to: endDate
        )!

        let sample = HKCategorySample(
            type: mindfulnessType,
            value: 0,
            start: startDate,
            end: endDate
        )

        healthStore.save(sample) { success, error in

            if let error {
                print("❌ Failed to save mindfulness session")
                print(error.localizedDescription)
                return
            }

            print("✅ Mindfulness session created")
            print("Duration: 10 minutes")
        }
    }
}
struct WorkoutSummary {
    let workoutType: String
    let durationMinutes: Double
    let startDate: Date
}
struct MindfulnessSessionSummary {
    let uuid: UUID = .init()
    let startDate: Date
    let endDate: Date
    var durationMinutes: Double {
        endDate.timeIntervalSince(startDate) / 60
    }
}
