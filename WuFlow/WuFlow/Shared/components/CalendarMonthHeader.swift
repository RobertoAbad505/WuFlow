//
//  CalendarMonthHeader.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/16/26.
//


import SwiftUI

struct CalendarMonthHeader: View {
    let month: Date
    let calendar: Calendar
    let onPrevious: () -> Void
    let onNext: () -> Void
    let canGoNext: Bool

    var body: some View {
        HStack {
            Button {
                onPrevious()
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.borderless)

            Spacer()

            Text(
                month,
                format: .dateTime.month(.wide).year()
            )
            .font(.headline)

            Spacer()

            Button {
                onNext()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.borderless)
            .disabled(!canGoNext)
        }
    }
}