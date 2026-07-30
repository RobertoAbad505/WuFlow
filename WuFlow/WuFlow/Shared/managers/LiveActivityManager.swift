//
//  LiveActivityManager.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/22/26.
//
import Foundation
import ActivityKit
import UIKit

final class LiveActivityManager: LiveActivityManaging {
    
    func ensureLiveActivity(for session: ActivePlaceSession) async {

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities are disabled.")
            return
        }

        if let _ = ActivityKit.Activity<PlaceSessionAttributes>.activities.first(
            where: {
                $0.attributes.sessionID == session.sessionID
            }
        ) {

            await update(session)
            return
        }

        do {
            try await start(session)
        } catch {
            print("❌ Failed to start Live Activity:", error)
        }
    }

    private func start(_ session: ActivePlaceSession) async throws {

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities disabled.")
            return
        }

        let activity = try ActivityKit.Activity<PlaceSessionAttributes>.request(
            attributes: makeAttributes(from: session),
            content: makeContent(from: session)
        )

        print("Started:", activity.id)
    }
    func update(_ session: ActivePlaceSession) async {

        guard let activity = ActivityKit.Activity<PlaceSessionAttributes>
            .activities
            .first(where: {
                $0.attributes.sessionID == session.sessionID
            })
        else {
            print("⚠️ Live Activity not found.")
            return
        }

        let content = ActivityContent(
            state: PlaceSessionAttributes.ContentState(
                startedAt: session.startedAt
            ),
            staleDate: nil
        )

        await activity.update(content)
        print("🟡 Live Activity updated")
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
    
    private func makeAttributes(
        from session: ActivePlaceSession
    ) -> PlaceSessionAttributes {

        PlaceSessionAttributes(
            sessionID: session.sessionID,
            activityName: session.placeName,
            placeName: session.placeName
        )
    }
    private func makeContent(
        from session: ActivePlaceSession
    ) -> ActivityContent<PlaceSessionAttributes.ContentState> {

        ActivityContent(
            state: .init(
                startedAt: session.startedAt
            ),
            staleDate: nil
        )
    }
}
protocol LiveActivityManaging {

    func ensureLiveActivity(for session: ActivePlaceSession) async

    func update(_ session: ActivePlaceSession) async

    func end(sessionID: UUID) async
}
struct ActivePlaceSession: Sendable {
    let sessionID: UUID
    let placeName: String
    let startedAt: Date
}
