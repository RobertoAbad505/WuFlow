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
    ) async {
        do {

            if try await repository.activePlaceSession(regionIdentifier: regionIdentifier) != nil {
                print("⚠️ Session already active.")
                return
            }

            let session = try await repository.createPlaceSession(
                regionIdentifier: regionIdentifier,
                trigger: trigger
            )
            print("✅ Session started \(session.id) in \(session.place.name)")
        } catch {

            print(error)

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
