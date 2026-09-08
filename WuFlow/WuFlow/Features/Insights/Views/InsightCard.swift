//
//  InsightCard.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/7/26.
//
import SwiftUI

struct InsightCard: View {

    let insight: Insight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Label(
                insight.title,
                systemImage: "lightbulb.fill"
            )
            .font(.headline)

            Text(insight.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}
