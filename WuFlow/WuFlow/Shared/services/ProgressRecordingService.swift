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
        context: ModelContext) throws {
        let record = ProgressRecord(
            value: value,
            source: source,
            activity: activity
        )
        context.insert(record)
        try context.save()
    }
}

enum ProgressSource {
    case manual
    case quickAction
    case notification
    case healthKit
    case location
}
