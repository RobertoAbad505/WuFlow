//
//  ProgressRecordingService.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 6/18/26.
//

import Foundation
import SwiftData

final class ProgressRecordingService {

    static let shared = ProgressRecordingService()

    private init() {}

    func recordProgress(
        for activity: Activity,
        value: Double,
        source: TrackingType,
        context: ModelContext
    ) throws {

        let record = ProgressRecord(
            value: value,
            source: source,
            activity: activity
        )

        context.insert(record)

        try context.save()

        print("✅ Progress saved")
        print("Activity:", activity.name)
        print("Value:", value)
        print("Source:", source.rawValue)
    }
}

enum ProgressSource {
    case manual
    case quickAction
    case notification
    case healthKit
    case location
}
