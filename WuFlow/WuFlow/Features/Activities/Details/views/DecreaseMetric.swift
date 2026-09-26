//
//  DecreaseMetric.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/21/26.
//
import SwiftUI

struct DecreaseMetric: View {
    let value: String
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.gray.opacity(0.2))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}
