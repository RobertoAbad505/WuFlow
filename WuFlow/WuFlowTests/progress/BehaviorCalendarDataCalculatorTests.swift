//
//  BehaviorCalendarDataCalculatorTests.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/16/26.
//


import XCTest
@testable import WuFlow

final class BehaviorCalendarDataCalculatorTests: XCTestCase {

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    func testBuildsCalendarDataFromBehaviorRecords() {
        let activity = Activity(
            name: "Reading",
            unitType: .count,
            goalValue: 1
        )

        let progress = ProgressRecord(
            value: 1,
            date: date("2026-09-01T10:00:00Z"),
            source: .manual,
            activity: activity
        )

        let observation = ObservationRecord(
            date: date("2026-09-02T10:00:00Z"),
            note: "Incident",
            activity: activity,
            kind: .incident
        )

        let calculator = BehaviorCalendarDataCalculator()

        let result = calculator.calculate(
            progressRecords: [progress],
            observations: [observation],
            from: date("2026-09-01"),
            to: date("2026-09-04"),
            calendar: utcCalendar
        )

        XCTAssertEqual(result.days.count, 3)
        XCTAssertEqual(result.positions.count, 5)

        XCTAssertEqual(result.days[0].progressCount, 1)
        XCTAssertEqual(result.days[0].incidentCount, 0)

        XCTAssertEqual(result.days[1].progressCount, 0)
        XCTAssertEqual(result.days[1].incidentCount, 1)
    }
    
    func testSeptemberFirstThroughThirdCreatesCompleteWeek() {
        let days = [
            BehaviorDay(
                date: date("2026-09-01"),
                progressValue: 1,
                progressCount: 1,
                incidentCount: 0
            ),
            BehaviorDay(
                date: date("2026-09-02"),
                progressValue: 1,
                progressCount: 1,
                incidentCount: 0
            ),
            BehaviorDay(
                date: date("2026-09-03"),
                progressValue: 1,
                progressCount: 1,
                incidentCount: 0
            )
        ]

        let calculator = BehaviorCalendarCalculator()

        let result = calculator.positions(
            for: days,
            calendar: utcCalendar
        )

        XCTAssertEqual(result.count, 7)

        XCTAssertNil(result[0].day)

        XCTAssertEqual(result[1].day?.date, date("2026-09-01"))
        XCTAssertEqual(result[2].day?.date, date("2026-09-02"))
        XCTAssertEqual(result[3].day?.date, date("2026-09-03"))

        XCTAssertNil(result[4].day)
        XCTAssertNil(result[5].day)
        XCTAssertNil(result[6].day)
    }

    private func date(_ string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: string) {
            return date
        }

        formatter.formatOptions = [.withFullDate]

        guard let date = formatter.date(from: string) else {
            XCTFail("Invalid date string: \(string)")
            return Date()
        }

        return date
    }
}
