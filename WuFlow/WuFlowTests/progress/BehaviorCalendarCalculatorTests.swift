//
//  BehaviorCalendarCalculatorTests.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/15/26.
//


import XCTest
@testable import WuFlow

final class BehaviorCalendarCalculatorTests: XCTestCase {

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2 // Monday
        return calendar
    }

    func testSeptemberFirstIsPositionedOnTuesday() {
        let day = BehaviorDay(
            date: date("2026-09-01"),
            progressValue: 0,
            progressCount: 0,
            incidentCount: 0
        )

        let calculator = BehaviorCalendarCalculator()

        let result = calculator.positions(
            for: [day],
            calendar: utcCalendar
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].weekIndex, 0)
        XCTAssertEqual(result[0].weekdayIndex, 1)
    }
    
    func testSeptemberSeventhStartsSecondWeek() {
        let days = [
            BehaviorDay(
                date: date("2026-09-01"),
                progressValue: 0,
                progressCount: 0,
                incidentCount: 0
            ),
            BehaviorDay(
                date: date("2026-09-07"),
                progressValue: 0,
                progressCount: 0,
                incidentCount: 0
            )
        ]

        let calculator = BehaviorCalendarCalculator()

        let result = calculator.positions(
            for: days,
            calendar: utcCalendar
        )

        XCTAssertEqual(result[0].weekIndex, 0)
        XCTAssertEqual(result[0].weekdayIndex, 1)

        XCTAssertEqual(result[1].weekIndex, 1)
        XCTAssertEqual(result[1].weekdayIndex, 0)
    }
    
    func testDaysWithinSameWeekShareWeekIndex() {
        let days = [
            BehaviorDay(
                date: date("2026-09-07"),
                progressValue: 0,
                progressCount: 0,
                incidentCount: 0
            ),
            BehaviorDay(
                date: date("2026-09-08"),
                progressValue: 1,
                progressCount: 1,
                incidentCount: 0
            ),
            BehaviorDay(
                date: date("2026-09-13"),
                progressValue: 2,
                progressCount: 2,
                incidentCount: 1
            )
        ]

        let calculator = BehaviorCalendarCalculator()

        let result = calculator.positions(
            for: days,
            calendar: utcCalendar
        )

        XCTAssertEqual(result[0].weekIndex, 0)
        XCTAssertEqual(result[0].weekdayIndex, 0)

        XCTAssertEqual(result[1].weekIndex, 0)
        XCTAssertEqual(result[1].weekdayIndex, 1)

        XCTAssertEqual(result[2].weekIndex, 0)
        XCTAssertEqual(result[2].weekdayIndex, 6)
    }

    func testFirstDayOfNextWeekGetsNextWeekIndex() {
        let days = [
            BehaviorDay(
                date: date("2026-09-07"),
                progressValue: 0,
                progressCount: 0,
                incidentCount: 0
            ),
            BehaviorDay(
                date: date("2026-09-14"),
                progressValue: 0,
                progressCount: 0,
                incidentCount: 0
            )
        ]

        let calculator = BehaviorCalendarCalculator()

        let result = calculator.positions(
            for: days,
            calendar: utcCalendar
        )

        XCTAssertEqual(result[0].weekIndex, 0)
        XCTAssertEqual(result[0].weekdayIndex, 0)

        XCTAssertEqual(result[1].weekIndex, 1)
        XCTAssertEqual(result[1].weekdayIndex, 0)
    }
    
    func testEmptyDaysReturnsEmptyPositions() {
        let calculator = BehaviorCalendarCalculator()

        let result = calculator.positions(
            for: [],
            calendar: utcCalendar
        )

        XCTAssertTrue(result.isEmpty)
    }
    func testOctoberFirstCreatesThreeLeadingEmptyCells() {
        let days = [
            BehaviorDay(
                date: date("2026-10-01"),
                progressValue: 0,
                progressCount: 0,
                incidentCount: 0
            )
        ]

        let calculator = BehaviorCalendarCalculator()

        let result = calculator.positions(
            for: days,
            calendar: utcCalendar
        )

        XCTAssertEqual(result.count, 4)

        XCTAssertNil(result[0].day)
        XCTAssertNil(result[1].day)
        XCTAssertNil(result[2].day)

        XCTAssertEqual(result[3].day?.date, date("2026-10-01"))

        XCTAssertEqual(result[0].weekdayIndex, 0)
        XCTAssertEqual(result[1].weekdayIndex, 1)
        XCTAssertEqual(result[2].weekdayIndex, 2)
        XCTAssertEqual(result[3].weekdayIndex, 3)
    }
    
    func testProgressModeReturnsProgressWhenDayHasProgress() {
        let day = BehaviorDay(
            date: date("2026-09-01"),
            progressValue: 2,
            progressCount: 1,
            incidentCount: 0
        )

        XCTAssertEqual(
            day.state(for: .progress),
            .progress
        )
    }
    
    func testIncidentModeReturnsIncidentWhenDayHasIncident() {
        let day = BehaviorDay(
            date: date("2026-09-01"),
            progressValue: 0,
            progressCount: 0,
            incidentCount: 1
        )

        XCTAssertEqual(
            day.state(for: .incidents),
            .incident
        )
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
