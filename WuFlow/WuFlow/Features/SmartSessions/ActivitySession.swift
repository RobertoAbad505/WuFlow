//
//  ActivitySession.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/21/26.
//
import Foundation

struct ActivitySession: Sendable {

    let activityID: UUID
    let activityName: String
    let startedAt: Date
    var endedAt: Date?
    let trigger: SessionTrigger

    var duration: TimeInterval? {
        guard let endedAt else { return nil }
        return endedAt.timeIntervalSince(startedAt)
    }

    var isActive: Bool {
        endedAt == nil
    }
}
