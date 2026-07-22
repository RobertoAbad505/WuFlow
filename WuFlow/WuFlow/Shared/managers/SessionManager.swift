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

    init(repository: ActivityRepository) {
        self.repository = repository
    }

    func startSession(
        regionIdentifier: String,
        trigger: SessionTrigger
    ) async -> PlaceSession? {
        do {
            if let activeSession = try await repository.activePlaceSession(regionIdentifier: regionIdentifier) {
                print("⚠️ Session already active.")
                print("Returning existing session")
                return activeSession
            }
            let session = try await repository.createPlaceSession(
                regionIdentifier: regionIdentifier,
                trigger: trigger
            )
            print("✅ Session started \(session.id) in \(session.place.name)")
            return session
        } catch {
            print(error)
            return nil
        }
    }
    func endSession(regionIdentifier: String) async -> PlaceSession? {
        do {
            return try await repository.endPlaceSession(regionIdentifier: regionIdentifier)
        } catch {
            print("""
            ❌ Failed to end session for '\(regionIdentifier)'
            \(error.localizedDescription)
            """)
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
