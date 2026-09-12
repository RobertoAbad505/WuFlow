//
//  DecreaseActivityCalculatorTests.swift
//  WuFlowTests
//
//  Created by Roberto Ramirez on 9/11/26.
//
import Foundation
import XCTest
@testable import WuFlow

final class DecreaseActivityCalculatorTests: XCTestCase {
    
    

    func testCalculate_withNoIncidents_returnsAwarenessDurationAsIncidentFreeDuration() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: [],
            now: now
        )

        XCTAssertEqual(
            summary.awarenessDuration,
            10.days,
            accuracy: 0.001
        )

        XCTAssertEqual(summary.incidentCount, 0)

        XCTAssertEqual(
            summary.currentIncidentFreeDuration,
            10.days,
            accuracy: 0.001
        )
    }
    
    func testCalculate_withOneIncident_returnsTimeSinceIncident() {
        let createdAt = date("2026-09-01")
        let incidentDate = date("2026-09-05")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let observation = makeObservation(
            incidentDate,
            activity: activity,
            kind: .incident
        )

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: [observation],
            now: now
        )

        XCTAssertEqual(summary.incidentCount, 1)

        XCTAssertEqual(
            summary.awarenessDuration,
            10.days,
            accuracy: 0.001
        )

        XCTAssertEqual(
            summary.currentIncidentFreeDuration,
            6.days,
            accuracy: 0.001
        )
    }
    
    func testCalculate_withMultipleIncidents_usesMostRecentIncident() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let observations = [
            makeObservation(
                date("2026-09-03"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-07"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-09"),
                activity: activity,
                kind: .incident
            )
        ]

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: observations,
            now: now
        )

        XCTAssertEqual(summary.incidentCount, 3)

        XCTAssertEqual(
            summary.currentIncidentFreeDuration,
            2.days,
            accuracy: 0.001
        )
    }
    
    func testCalculate_ignoresNonIncidentObservations() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let note = makeObservation(
            date("2026-09-07"),
            activity: activity,
            kind: ObservationKind.note
        )

        let incident = makeObservation(
            date("2026-09-05"),
            activity: activity,
            kind: ObservationKind.incident
        )

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: [note, incident],
            now: now
        )

        XCTAssertEqual(summary.incidentCount, 1)

        XCTAssertEqual(
            summary.currentIncidentFreeDuration,
            6.days,
            accuracy: 0.001
        )
    }
    
    func testCalculate_ignoresIncidentsFromOtherActivities() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let smoking = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let socialMedia = makeActivity(
            name: "Social Media",
            createdAt: createdAt
        )

        let smokingIncident = makeObservation(
            date("2026-09-07"),
            activity: smoking,
            kind: .incident
        )

        let socialMediaIncident = makeObservation(
            date("2026-09-09"),
            activity: socialMedia,
            kind: .incident
        )

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: smoking,
            observations: [
                smokingIncident,
                socialMediaIncident
            ],
            now: now
        )

        XCTAssertEqual(summary.incidentCount, 1)

        XCTAssertEqual(
            summary.currentIncidentFreeDuration,
            4.days,
            accuracy: 0.001
        )
    }
    func testCalculate_withFutureIncident_clampsIncidentFreeDurationToZero() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let observation = makeObservation(
            date("2026-09-12"),
            activity: activity,
            kind: .incident
        )

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: [observation],
            now: now
        )

        XCTAssertEqual(
            summary.currentIncidentFreeDuration,
            0,
            accuracy: 0.001
        )
    }
    func testCalculate_whenActivityCreatedInFuture_clampsAwarenessDurationToZero() {
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: date("2026-09-12")
        )

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: [],
            now: now
        )

        XCTAssertEqual(
            summary.awarenessDuration,
            0,
            accuracy: 0.001
        )

        XCTAssertEqual(
            summary.currentIncidentFreeDuration,
            0,
            accuracy: 0.001
        )
    }
    
    func testCalculate_withNoIncidents_returnsEntireAwarenessAsLongestIncidentFreeDuration() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: [],
            now: now
        )

        XCTAssertEqual(
            summary.longestIncidentFreeDuration,
            10.days,
            accuracy: 0.001
        )
    }
    
    func testCalculate_withOneIncident_returnsLongestIncidentFreePeriod() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let incident = makeObservation(
            date("2026-09-05"),
            activity: activity,
            kind: .incident
        )

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: [incident],
            now: now
        )

        XCTAssertEqual(
            summary.longestIncidentFreeDuration,
            6.days,
            accuracy: 0.001
        )
    }
    
    func testCalculate_withMultipleIncidents_returnsLongestIncidentFreePeriod() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let observations = [
            makeObservation(
                date("2026-09-03"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-08"),
                activity: activity,
                kind: .incident
            )
        ]

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: observations,
            now: now
        )

        XCTAssertEqual(
            summary.longestIncidentFreeDuration,
            5.days,
            accuracy: 0.001
        )
    }
    
    func testCalculate_whenLongestPeriodIsBeforeFirstIncident_returnsThatPeriod() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let observations = [
            makeObservation(
                date("2026-09-09"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-10"),
                activity: activity,
                kind: .incident
            )
        ]

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: observations,
            now: now
        )

        XCTAssertEqual(
            summary.longestIncidentFreeDuration,
            8.days,
            accuracy: 0.001
        )
    }
    
    func testCalculate_withOneIncident_returnsNilAverageIncidentInterval() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let incident = makeObservation(
            date("2026-09-05"),
            activity: activity,
            kind: .incident
        )

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: [incident],
            now: now
        )

        XCTAssertNil(summary.averageIncidentInterval)
    }
    func testCalculate_withUnsortedIncidents_returnsCorrectAverageInterval() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let observations = [
            makeObservation(
                date("2026-09-09"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-03"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-07"),
                activity: activity,
                kind: .incident
            )
        ]

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: observations,
            now: now
        )

        XCTAssertEqual(
            summary.averageIncidentInterval!,
            3.days,
            accuracy: 0.001
        )
    }
    
    func testCalculate_withMultipleIncidents_returnsAverageIncidentInterval() {
        let createdAt = date("2026-09-01")
        let now = date("2026-09-11")

        let activity = makeActivity(
            name: "Smoking",
            createdAt: createdAt
        )

        let observations = [
            makeObservation(
                date("2026-09-03"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-07"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-09"),
                activity: activity,
                kind: .incident
            )
        ]

        let calculator = DecreaseActivityCalculator()

        let summary = calculator.calculate(
            activity: activity,
            observations: observations,
            now: now
        )

        XCTAssertEqual(
            summary.averageIncidentInterval!,
            3.days,
            accuracy: 0.001
        )
    }
    
    private func date(_ string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: "\(string)T00:00:00Z")!
    }

    private func makeObservation( _ date: Date, activity: Activity, kind: ObservationKind = .note) -> ObservationRecord {
        return ObservationRecord(
            date: date,
            note: "TEST",
            activity: activity,
            kind: kind
        )
    }
    private func makeActivity(
        name: String,
        createdAt: Date
    ) -> Activity {

        let activity = Activity(
            name: name,
            unitType: .count,
            goalValue: 10,
            createdAt: createdAt
        )

        return activity
    }
}
private extension TimeInterval {
    var days: TimeInterval {
        self * 24 * 60 * 60
    }
}
