//
//  SessionDurationCalculator.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/4/26.
//
import Foundation

final class SessionDurationCalculator {

    func expectedDuration(
        from sessions: [PlaceSession]
    ) -> TimeInterval? {

        let durations = sessions
            .compactMap(\.duration)
            .sorted()

        guard durations.count >= 3 else {
            print("⚠️ No expected duration can be calculated")
            return nil
        }

        let middleIndex = durations.count / 2

        if durations.count.isMultiple(of: 2) {
            let lower = durations[middleIndex - 1]
            let upper = durations[middleIndex]

            return (lower + upper) / 2
        } else {
            return durations[middleIndex]
        }
    }
}
final class SessionProgressCalculator {

    func progress(
        startedAt: Date,
        expectedDuration: TimeInterval,
        now: Date = .now
    ) -> Double {
        let elapsed = now.timeIntervalSince(startedAt)

        guard expectedDuration > 0 else {
            return 0
        }

        return min(elapsed / expectedDuration, 1)
    }
}
