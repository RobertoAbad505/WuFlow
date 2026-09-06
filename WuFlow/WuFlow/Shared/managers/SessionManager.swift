//
//  SessionManager.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/21/26.
//

import Foundation
import SwiftData


actor SessionManager {
    
    private let repository: ActivityRepository
    private let durationCalculator: SessionDurationCalculator

    init(
        repository: ActivityRepository,
        durationCalculator: SessionDurationCalculator
    ) {
        self.repository = repository
        self.durationCalculator = durationCalculator
    }


    func startSession(
        activity: Activity,
        regionIdentifier: String,
        trigger: SessionTrigger,
        icon: String? = nil
    ) async -> ActivePlaceSession? {

        do {
            if let activeSession = try await repository.activePlaceSession(
                regionIdentifier: regionIdentifier
            ) {
                print("⚠️ Session already active.")
                
                return activeSession.activePlaceSession(
                    expectedDuration: nil
                )
            }

            let session = try await repository.createPlaceSession(
                activity: activity,
                regionIdentifier: regionIdentifier,
                trigger: trigger,
                icon: icon
            )

            let historicalSessions = try await repository.placeSessions(
                for: activity.id
            )

            let expectedDuration = await durationCalculator.expectedDuration(
                from: historicalSessions
            )

            print("✅ Session started")
            print("Expected duration:", expectedDuration ?? 0)

            return session.activePlaceSession(
                expectedDuration: expectedDuration
            )

        } catch {
            print("❌ Failed to start session:", error)
            return nil
        }
    }
    func endSession(regionIdentifier: String) async -> PlaceSession? {
        do {
            let sessionEnded = try await repository.endPlaceSession(regionIdentifier: regionIdentifier)
            print("Session at \(sessionEnded.place.name) ended; active:", sessionEnded.isActive)
            return sessionEnded
        } catch {
            print("""
            ❌ Failed to end session for '\(regionIdentifier)'
            \(error.localizedDescription)
            """)
            return nil
        }
    }
    
    func expectedDuration(
        for activity: Activity
    ) async -> TimeInterval? {

        do {
            let sessions = try await repository.placeSessions(
                for: activity.id
            )

            return durationCalculator.expectedDuration(
                from: sessions
            )

        } catch {
            print("Failed to calculate expected session duration:", error)
            return nil
        }
    }
    
    func activePlaceSession() async -> ActivePlaceSession? {
        do {
            guard let session = try await repository.activePlaceSession(),
                  let activity = session.activity
            else {
                return nil
            }

            let sessions = try await repository.placeSessions(
                for: activity.id
            )

            let expectedDuration = durationCalculator.expectedDuration(
                from: sessions
            )

            return session.activePlaceSession(
                expectedDuration: expectedDuration
            )

        } catch {
            print(error)
            return nil
        }
    }
}
enum SessionTrigger: String, Sendable, Codable {
    case location
    case reminder
    case healthKit
    case manual
    case shortcut
}
