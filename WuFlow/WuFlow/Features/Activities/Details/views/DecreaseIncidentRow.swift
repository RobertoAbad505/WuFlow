//
//  DecreaseIncidentRow.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/14/26.
//


import SwiftUI

struct DecreaseIncidentRow: View {

    let observation: ObservationRecord

    var body: some View {
        HStack(spacing: 14) {

            Image(systemName: "exclamationmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {

                Text(
                    observation.date,
                    format: .dateTime.month().day().year()
                )
                .font(.subheadline)
                .fontWeight(.semibold)

                Text(
                    observation.date,
                    format: .dateTime.hour().minute()
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}
