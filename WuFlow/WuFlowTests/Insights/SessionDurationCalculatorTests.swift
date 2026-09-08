//
//  SessionDurationCalculatorTests.swift
//  WuFlowTests
//
//  Created by Roberto Ramirez on 9/7/26.
//

import Testing
import XCTest
@testable import WuFlow


final class SessionDurationCalculatorTests: XCTestCase {

    private let calculator = SessionDurationCalculator()

    private let activity = Activity(
        name: "Gym",
        unitType: .sessions,
        goalValue: 5,
        goalPeriod: .weekly
    )

    private let place = Place(
        identifier: "gym.test",
        name: "Test Gym",
        latitude: 0,
        longitude: 0,
        radius: 100
    )

    func testExpectedDurationUsesMedian() throws {

        // Given
        let sessions = [
            makeSession(duration: 52 * 60),
            makeSession(duration: 61 * 60),
            makeSession(duration: 58 * 60),
            makeSession(duration: 67 * 60),
            makeSession(duration: 55 * 60)
        ]

        // When
        let result = calculator.expectedDuration(
            from: sessions
        )

        // Then
        XCTAssertEqual(
            result,
            58 * 60
        )
    }
    
    func testExpectedDurationRequiresAtLeastThreeSessions() throws {

        // Given
        let sessions = [
            makeSession(duration: 52 * 60),
            makeSession(duration: 61 * 60)
        ]

        // When
        let result = calculator.expectedDuration(
            from: sessions
        )

        // Then
        XCTAssertNil(result)
    }
    
    func testExpectedDurationIgnoresIncompleteSessions() throws {

        // Given
        let sessions = [
            makeSession(duration: 52 * 60),
            makeSession(duration: 61 * 60),
            makeSession(duration: 58 * 60),
            makeSession(duration: 0)
        ]

        // When
        let result = calculator.expectedDuration(
            from: sessions
        )
        print("🧪 Test durations:")

        for session in sessions {
            print(session.duration ?? -1)
        }

        // Then
        XCTAssertEqual(result, 58 * 60)
    }

    private func makeSession(
        duration: TimeInterval
    ) -> PlaceSession {

        let startedAt = Date()

        let session = PlaceSession(
            activity: activity,
            place: place,
            trigger: .manual,
            icon: nil
        )

        session.startedAt = startedAt
        session.endedAt = startedAt.addingTimeInterval(duration)

        return session
    }
}
