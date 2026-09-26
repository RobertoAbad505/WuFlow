//
//  BehaviorDayCalculatorTests.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/15/26.
//


import XCTest
@testable import WuFlow

final class BehaviorDayCalculatorTests: XCTestCase {
    
    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
    
    func testBehaviorDayStoresDailyValues() {
        let day = BehaviorDay(
            date: date("2026-09-15"),
            progressValue: 30,
            progressCount: 2,
            incidentCount: 1
        )

        XCTAssertEqual(day.date, date("2026-09-15"))
        XCTAssertEqual(day.progressValue, 30)
        XCTAssertEqual(day.progressCount, 2)
        XCTAssertEqual(day.incidentCount, 1)
    }
    
    func testAggregatesProgressRecordsFromSameDay() {
        let activity = makeActivity()

        let records = [
            ProgressRecord(
                value: 10,
                date: date("2026-09-15T09:00:00Z"),
                source: .manual,
                activity: activity
            ),
            ProgressRecord(
                value: 20,
                date: date("2026-09-15T15:00:00Z"),
                source: .manual,
                activity: activity
            )
        ]

        let calculator = BehaviorDayCalculator()

        let result = calculator.calculate(
            progressRecords: records,
            observations: [],
            from: date("2026-09-15"),
            to: date("2026-09-16"),
            calendar: utcCalendar
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].progressValue, 30)
        XCTAssertEqual(result[0].progressCount, 2)
        XCTAssertEqual(result[0].incidentCount, 0)
    }
    
    func testCreatesEmptyDaysWithoutProgressRecords() {
        let activity = makeActivity()

        let records = [
            ProgressRecord(
                value: 10,
                date: date("2026-09-15T09:00:00Z"),
                source: .manual,
                activity: activity
            )
        ]

        let calculator = BehaviorDayCalculator()

        let result = calculator.calculate(
            progressRecords: records,
            observations: [],
            from: date("2026-09-15"),
            to: date("2026-09-18"),
            calendar: utcCalendar
        )

        XCTAssertEqual(result.count, 3)

        XCTAssertEqual(result[0].date, date("2026-09-15"))
        XCTAssertEqual(result[0].progressValue, 10)
        XCTAssertEqual(result[0].progressCount, 1)

        XCTAssertEqual(result[1].date, date("2026-09-16"))
        XCTAssertEqual(result[1].progressValue, 0)
        XCTAssertEqual(result[1].progressCount, 0)

        XCTAssertEqual(result[2].date, date("2026-09-17"))
        XCTAssertEqual(result[2].progressValue, 0)
        XCTAssertEqual(result[2].progressCount, 0)
    }
    func testCountsIncidentsForSameDay() {
        let activity = makeActivity()

        let observations = [
            makeObservation(
                date("2026-09-15T09:00:00Z"),
                activity: activity,
                kind: .note
            ),
            makeObservation(
                date("2026-09-15T12:00:00Z"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-15T15:00:00Z"),
                activity: activity,
                kind: .incident
            )
        ]

        let calculator = BehaviorDayCalculator()

        let result = calculator.calculate(
            progressRecords: [],
            observations: observations,
            from: date("2026-09-15"),
            to: date("2026-09-16"),
            calendar: utcCalendar
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].incidentCount, 2)
    }
    func testNormalObservationsDoNotCountAsIncidents() {
        let activity = makeActivity()

        let observations = [
            makeObservation(
                date("2026-09-15T09:00:00Z"),
                activity: activity,
                kind: .note
            ),
            makeObservation(
                date("2026-09-15T12:00:00Z"),
                activity: activity,
                kind: .note
            )
        ]

        let calculator = BehaviorDayCalculator()

        let result = calculator.calculate(
            progressRecords: [],
            observations: observations,
            from: date("2026-09-15"),
            to: date("2026-09-16"),
            calendar: utcCalendar
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].incidentCount, 0)
    }
    
    func testSeparatesIncidentsByDay() {
        let activity = makeActivity()

        let observations = [
            makeObservation(
                date("2026-09-15T10:00:00Z"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-16T10:00:00Z"),
                activity: activity,
                kind: .incident
            ),
            makeObservation(
                date("2026-09-16T15:00:00Z"),
                activity: activity,
                kind: .incident
            )
        ]

        let calculator = BehaviorDayCalculator()

        let result = calculator.calculate(
            progressRecords: [],
            observations: observations,
            from: date("2026-09-15"),
            to: date("2026-09-17"),
            calendar: utcCalendar
        )

        XCTAssertEqual(result.count, 2)

        XCTAssertEqual(result[0].incidentCount, 1)
        XCTAssertEqual(result[1].incidentCount, 2)
    }
    
    private func makeActivity() -> Activity {
        Activity(
            name: "Test Activity",
            unitType: .count,
            goalValue: 10,
            createdAt: date("2026-09-01T00:00:00Z")
        )
    }

    private func date(_ string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if string.contains("T") {
            guard let date = formatter.date(from: string) else {
                XCTFail("Invalid ISO8601 date: \(string)")
                return Date()
            }

            return date
        }

        formatter.formatOptions = [.withFullDate]

        guard let date = formatter.date(from: string) else {
            XCTFail("Invalid date: \(string)")
            return Date()
        }

        return date
    }
    
    private func makeObservation(
        _ date: Date,
        activity: Activity,
        kind: ObservationKind = .note
    ) -> ObservationRecord {
        ObservationRecord(
            date: date,
            note: "TEST",
            activity: activity,
            kind: kind
        )
    }
}
