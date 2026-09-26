//
//  BehaviorDayDetailView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/16/26.
//


import SwiftUI

struct BehaviorDayDetailView: View {
    let day: BehaviorDay
    let mode: BehaviorCalendarMode

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text(
                    day.date,
                    format: .dateTime
                        .weekday(.wide)
                        .month(.wide)
                        .day()
                        .year()
                )
                .font(.title2)
                .fontWeight(.semibold)

                switch mode {
                case .progress:
                    progressContent

                case .incidents:
                    incidentContent
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Day")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }

    private var progressContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                "\(day.progressCount) progress records",
                systemImage: "chart.bar"
            )

            Text(
                "Total value: \(day.progressValue, specifier: "%.1f")"
            )
            .foregroundStyle(.secondary)
        }
    }

    private var incidentContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                "\(day.incidentCount) incidents",
                systemImage: "exclamationmark.circle"
            )

            if day.incidentCount == 0 {
                Text("No incidents were recorded on this day.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}