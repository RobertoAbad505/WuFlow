//
//  SessionProgressView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/5/26.
//
import ActivityKit
import WidgetKit
import SwiftUI

struct SessionProgressView: View {

    private var isPastExpectedDuration: Bool {
        guard let expectedEndDate else {
            return false
        }

        return Date() >= expectedEndDate
    }
    
    let context: ActivityViewContext<PlaceSessionAttributes>

    private var expectedEndDate: Date? {
        guard let expectedDuration = context.attributes.expectedDuration else {
            return nil
        }

        return context.state.startedAt
            .addingTimeInterval(expectedDuration)
    }    

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let expectedEndDate {
                ProgressView(
                    timerInterval: context.state.startedAt...expectedEndDate,
                    countsDown: false,
                    label: {
                        EmptyView()
                    },
                    currentValueLabel: {EmptyView()}
                )
                .tint(progressTint)
            }
        }
    }
    private var progressTint: Color {
        guard let expectedEndDate else {
            return .blue
        }

        let expectedDuration = expectedEndDate.timeIntervalSince(
            context.state.startedAt
        )

        let elapsed = Date().timeIntervalSince(
            context.state.startedAt
        )

        let progress = elapsed / expectedDuration

        switch progress {
        case 0..<0.75:
            return .blue
        case 0.75..<1.0:
            return .green
        default:
            return .yellow
        }
    }
}
#Preview("Lock Screen", as: .content, using: PlaceSessionAttributes.preview) {
    WuFlowWidgetLiveActivity()
} contentStates: {
    .oneHour
}
