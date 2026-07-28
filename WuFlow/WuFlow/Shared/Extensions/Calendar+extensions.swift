import Foundation

extension Calendar {

    func days(
        from start: Date,
        to end: Date
    ) -> [Date] {

        var dates: [Date] = []

        var current = startOfDay(for: start)

        while current <= end {

            dates.append(current)

            current = date(
                byAdding: .day,
                value: 1,
                to: current
            )!
        }

        return dates

    }

}
extension Calendar {

    func isDate(
        _ date: Date,
        inSameDayAs target: Date
    ) -> Bool {

        let start = startOfDay(for: target)
        let end = self.date(byAdding: .day, value: 1, to: start)!

        return date >= start && date < end
    }
}
