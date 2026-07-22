//
//  LocationAutomationEngine.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/15/26.
//
import Foundation
import Observation

@Observable
final class LocationAutomationEngine {

    let sessionManager: SessionManager
    private let repository: ActivityRepository

    init(repository: ActivityRepository, sessionManager: SessionManager) {
        self.repository = repository
        self.sessionManager = sessionManager
    }

    func handle(
        regionIdentifier: String,
        event: RegionEvent
    ) async {

        guard let activity = try? await repository
            .activities(placeIdentifier: regionIdentifier)
            .first
        else {
            return
        }

        await activitySessionCheck(
            activity: activity,
            regionIdentifier: regionIdentifier,
            event: event
        )
    }
    private func activitySessionCheck(
        activity: Activity,
        regionIdentifier: String,
        event: RegionEvent
    ) async {

        switch event {

        case .entered:
            print("Entered region-identifier:\(regionIdentifier)")
            await sessionManager.startSession(
                regionIdentifier: regionIdentifier,
                trigger: .location
            )

            NotificationManager.shared
                .sendPlaceSessionStarted(activity: activity)

        case .exited:
            print("Exited region-identifier:\(regionIdentifier)")
            guard let session = await sessionManager.endSession(
                regionIdentifier: regionIdentifier
            ) else {
                return
            }

            NotificationManager.shared
                .sendPlaceSessionCompleted(
                    activity: activity,
                    session: session
                )

        default:
            break
        }
    }
}

enum RegionEvent: String {
    case entered = "Entered"
    case exited = "Exited"
    case stateChanged = "StateChanged"
    case dwell = "Dwell"
}
extension RegionEvent {

    func notificationBody(
        for activity: Activity
    ) -> String {

        switch self {

        case .entered:
            return """
            You arrived at \(activity.place?.name ?? "your destination").
            Ready to complete "\(activity.name)"?
            """

        case .exited:
            return """
            You left \(activity.place?.name ?? "your destination").
            Did you complete "\(activity.name)"?
            """

        case .stateChanged:
            return """
            Your location has changed for "\(activity.name)".
            """

        case .dwell:
            return """
            You've been at \(activity.place?.name ?? "this place") for a while.
            Would you like to record "\(activity.name)"?
            """
        }
    }
}

