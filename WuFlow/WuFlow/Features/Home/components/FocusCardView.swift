//
//  FocusCardView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/23/26.
//
import SwiftUI

struct FocusCardView: View {

    let item: ActivitySummary
    let action: () -> Void

    var body: some View {

        Button(action: action) {
            VStack(spacing: 5) {
                activityImage
                VStack {
                    Text(item.activity.name)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .lineLimit(5)
                    Text(progressDescription)
                        .font(.caption)
                    ProgressView(value: item.progress.ratio)
                        .tint(progressColor)
                }
                .padding()
            }
            .foregroundStyle(.black)
            .background(.ultraThinMaterial)
            .frame(maxWidth: 120, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    var activityImage: some View {
        ActivityImageView(path: item.activity.imagePath, icon: item.activity.iconName)
            .frame(maxWidth: 60, maxHeight: 80)
            .padding(.top, item.activity.imagePath == nil ? 20:0)
    }
}

private extension FocusCardView {

    var progressDescription: String {
        "\(Int(item.progress.value)) / \(Int(item.progress.goal)) \(item.activity.measurement.displayName)"
    }
    var progressColor: Color {
        switch item.progress.status {
        case .exceeded:
            return .orange
        case .completed:
            return .green
        case .inProgress:
            return .blue
        case .notStarted:
            return .gray
        }
    }
}
