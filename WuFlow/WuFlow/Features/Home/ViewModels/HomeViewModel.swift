//
//  HomeViewModel.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 8/19/26.
//
import Combine
import SwiftUI

@Observable
final class HomeViewModel {

    private let repository: ActivityRepository
    private let progressCalculator: ProgressCalculator

    var focusCards: [ActivitySummary] = []

    init(
        repository: ActivityRepository,
        progressCalculator: ProgressCalculator
    ) {
        self.repository = repository
        self.progressCalculator = progressCalculator
    }

    func load(
        activities: [Activity]
    ) throws {

        focusCards = try activities
            .prefix(5)
            .map { activity in

                let records = try repository.progressRecords(
                    for: activity.id
                )

                let progress = progressCalculator.progress(
                    for: activity,
                    records: records
                )

                return ActivitySummary(
                    activity: activity,
                    progress: progress
                )
            }
    }
}
