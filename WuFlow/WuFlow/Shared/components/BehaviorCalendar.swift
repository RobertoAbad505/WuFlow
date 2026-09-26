//
//  BehaviorCalendar.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/15/26.
//


import SwiftUI


struct BehaviorCalendar: View {
    let positions: [CalendarDayPosition]
    let calendar: Calendar
    let mode: BehaviorCalendarMode
    let onDaySelected: (BehaviorDay) -> Void
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 7
    )

    var body: some View {
        VStack(spacing: 12) {
            weekdayHeader

            LazyVGrid(
                columns: columns,
                spacing: 8
            ) {
                ForEach(positions) { position in
                    dayCell(position)
                }
            }
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(
            columns: columns,
            spacing: 8
        ) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let firstIndex = calendar.firstWeekday - 1

        return Array(
            symbols[firstIndex...] + symbols[..<firstIndex]
        )
    }

    @ViewBuilder
    private func dayCell(
        _ position: CalendarDayPosition
    ) -> some View {
        if let day = position.day {
            Button(action: {
                onDaySelected(day)
            }, label: {
                behaviorDayCell(day)
            })
        } else {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
        }
    }
    private func behaviorDayCell(
        _ day: BehaviorDay
    ) -> some View {
        let state = day.state(for: mode)

        return ZStack {
            background(for: state)

            VStack(spacing: 3) {
                Text(
                    day.date,
                    format: .dateTime.day()
                )
                .font(.caption)
                .fontWeight(.medium)

                if state == .incident {
                    incidentIndicator(for: day)
                }
            }
        }
        .tint(.black)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
        )
    }
    @ViewBuilder
    private func background(
        for state: BehaviorDayState
    ) -> some View {
        switch state {
        case .empty:
            Color.clear

        case .progress:
            Color.primary.opacity(0.15)

        case .incident:
            Color.primary.opacity(0.25)
        }
    }
    private func incidentIndicator(
        for day: BehaviorDay
    ) -> some View {
        Circle()
            .fill(.primary)
            .frame(width: 6, height: 6)
    }
    private func progressCell(
        for day: BehaviorDay
    ) -> some View {
        Text(
            day.date,
            format: .dateTime.day()
        )
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(
            day.progressCount > 0
            ? AnyShapeStyle(.thinMaterial)
            : AnyShapeStyle(Color.clear)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
    }
    private func incidentCell(
        for day: BehaviorDay
    ) -> some View {
        Text(
            day.date,
            format: .dateTime.day()
        )
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(
            day.incidentCount > 0
            ? AnyShapeStyle(.thinMaterial)
            : AnyShapeStyle(Color.clear)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
    }
}

enum BehaviorCalendarMode: Sendable {
    case progress
    case incidents
}
enum BehaviorDayState: Sendable, Equatable {
    case empty
    case progress
    case incident
}
#Preview {
    let calendar = Calendar(identifier: .gregorian)
    
    let days = (1...30).map { day in
        BehaviorDay(
            date: calendar.date(
                from: DateComponents(
                    year: 2026,
                    month: 08,
                    day: day
                )
            )!,
            progressValue: Double(day),
            progressCount: day % 3,
            incidentCount: day % 5 == 0 ? 1 : 0
        )
    }
    
    let calculator = BehaviorCalendarCalculator()
    
    let positions = calculator.positions(
        for: days,
        calendar: calendar
    )
    
    BehaviorCalendar(
        positions: positions,
        calendar: calendar,
        mode: BehaviorCalendarMode.progress,
        onDaySelected: { day in
            print(day.date)
        }
    )
    .padding()
    
}
