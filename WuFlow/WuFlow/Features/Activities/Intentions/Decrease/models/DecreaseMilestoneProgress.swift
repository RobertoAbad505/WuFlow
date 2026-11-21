import Foundation

struct DecreaseMilestoneProgress: Sendable {
    let currentDuration: TimeInterval
    let targetDuration: TimeInterval
    let progress: Double

    var targetLabel: String {
        let days = Int(targetDuration / Self.secondsPerDay)
        return "\(days) \(days == 1 ? "day" : "days")"
    }

    var currentDurationLabel: String {
        DurationFormatter.string(from: currentDuration)
    }

    var percentage: Int {
        Int((progress * 100).rounded())
    }

    private static let secondsPerDay: TimeInterval = 24 * 60 * 60
}

/// Provides the next incident-free milestone for decrease activities.
final class DecreaseMilestoneCalculator {
    private let milestoneDays: [Double] = [1, 3, 7, 14, 30, 60, 90, 180, 365]

    func progress(currentDuration: TimeInterval) -> DecreaseMilestoneProgress {
        let elapsed = max(currentDuration, 0)
        let target = nextMilestone(after: elapsed)

        return DecreaseMilestoneProgress(
            currentDuration: elapsed,
            targetDuration: target,
            progress: min(elapsed / target, 1)
        )
    }

    private func nextMilestone(after duration: TimeInterval) -> TimeInterval {
        let secondsPerDay = 24.0 * 60 * 60

        if let days = milestoneDays.first(where: { duration < $0 * secondsPerDay }) {
            return days * secondsPerDay
        }

        let elapsedYears = floor(duration / (365 * secondsPerDay))
        return (elapsedYears + 1) * 365 * secondsPerDay
    }
}
