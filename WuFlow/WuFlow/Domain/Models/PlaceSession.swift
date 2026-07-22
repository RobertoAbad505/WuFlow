//
//  PlaceSession.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/21/26.
//
import Foundation
import SwiftData

@Model
final class PlaceSession {

    @Attribute(.unique)
    var id: UUID

    var startedAt: Date

    var endedAt: Date?

    var triggerValue: String

    var trigger: SessionTrigger {
        get {
            SessionTrigger(rawValue: triggerValue) ?? .manual
        }
        set {
            triggerValue = newValue.rawValue
        }
    }

    @Relationship
    var place: Place

    init(
        place: Place,
        trigger: SessionTrigger
    ) {
        self.id = UUID()
        self.startedAt = .now
        self.place = place
        self.triggerValue = trigger.rawValue
    }
    func end() {
        endedAt = .now
    }
}
extension PlaceSession {
    var isActive: Bool {
        endedAt == nil
    }

    var duration: TimeInterval? {
        guard let endedAt else { return nil }
        return endedAt.timeIntervalSince(startedAt)
    }
    var formattedDuration: String {
        guard let duration else {
            return "In Progress"
        }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated

        return formatter.string(from: duration) ?? "-"
    }
}
