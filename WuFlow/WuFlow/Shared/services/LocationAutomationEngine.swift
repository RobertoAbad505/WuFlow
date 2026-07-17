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

    private let repository: ActivityRepository

    init(repository: ActivityRepository) {
        self.repository = repository
    }

    func handle(regionIdentifier: String, event: RegionEvent) async {
        guard let activities = try? await repository.activities(placeIdentifier: regionIdentifier).first else {
            print("No activities found for \(regionIdentifier)")
            return
        }
        NotificationManager.shared.sendGeoFenceNotification(activity: activities, event: event)
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

