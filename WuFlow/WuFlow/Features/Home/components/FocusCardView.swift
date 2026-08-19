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
            VStack(spacing: 10) {
                activityImage
                VStack {
                    Text(item.activity.name)
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    Text(progressDescription)
                        .font(.caption)

                    ProgressView(value: item.progress.ratio)
                        .tint(progressColor)
                }
                .padding()
            }
            .foregroundStyle(.black)
        }
    }
    var activityImage: some View {
        VStack {
            ActivityImageView(path: item.activity.imagePath, icon: item.activity.iconName)
                .frame(maxWidth: 50, maxHeight: 50)
        }
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
