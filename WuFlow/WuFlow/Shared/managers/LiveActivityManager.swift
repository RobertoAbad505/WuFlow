//
//  LiveActivityManager.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/22/26.
//
import Foundation
import ActivityKit

final class LiveActivityManager: LiveActivityManaging {

    func start(_ session: LiveSession) async throws {

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are disabled.")
            return
        }

        let attributes = PlaceSessionAttributes(
            sessionID: session.sessionID,
            activityName: session.activityName,
            placeName: session.placeName
        )

        let content = ActivityContent(
            state: PlaceSessionAttributes.ContentState(startedAt: session.startedAt),
            staleDate: nil
        )

        _ = try ActivityKit.Activity.request(
            attributes: attributes,
            content: content
        )

        print("🟢 Live Activity started")

    }

    func end(sessionID: UUID) async {

        guard let activity = ActivityKit.Activity<PlaceSessionAttributes>
            .activities
            .first(where: {
                $0.attributes.sessionID == sessionID
            })
        else {
            print("No Live Activity found.")
            return
        }

        await activity.end(nil, dismissalPolicy: .immediate)

        print("🔴 Live Activity ended")
    }
}
protocol LiveActivityManaging {

    func start(_ session: LiveSession) async throws

    func end(sessionID: UUID) async

}
struct LiveSession: Sendable {
    let sessionID: UUID
    let activityName: String
    let placeName: String
    let startedAt: Date
}
