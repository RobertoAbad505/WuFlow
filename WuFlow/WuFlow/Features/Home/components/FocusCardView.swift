//
//  FocusCardView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/23/26.
//
import SwiftUI

struct FocusCardView: View {

    let item: FocusActivityCardItem
    let action: () -> Void

    private let cardWidth: CGFloat = 170
    private let cardHeight: CGFloat = 190

    var body: some View {

        Button(action: action) {
            ZStack {
                activityImage
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.76)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                VStack(alignment: .leading, spacing: 6) {
                    Spacer(minLength: 0)
                    Text(item.activity.name)
                        .font(.subheadline.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundStyle(.white)
                    summaryView
                }
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.activity.name), \(item.accessibilitySummary)")
        .overlay {
            if case .progress(let progress) = item.summary,
               progress.status == .exceeded {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.oceanBlue, lineWidth: 2)
            }
        }
    }

    private var activityImage: some View {
        ZStack {
            AppColors.mistBlue
            if item.activity.imagePath != nil {
                ActivityImageView(
                    path: item.activity.imagePath,
                    icon: item.activity.iconName,
                    contentMode: .fill
                )
            } else {
                Image(systemName: item.activity.iconName ?? "circle.dotted")
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.midnightNavy)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipped()
    }
}

private extension FocusCardView {
    @ViewBuilder
    var summaryView: some View {
        switch item.summary {
        case .progress(let progress):
            Text("\(Int(progress.value)) / \(Int(progress.goal)) \(item.activity.measurement.displayName)")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.9))
            ProgressView(value: progress.ratio)
                .tint(AppColors.oceanBlue)

        case .decrease(let summary):
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.subheadline.weight(.semibold))
                VStack(alignment: .leading, spacing: 1) {
                    Text("Incident-free")
                        .font(.caption)
                    Text(DurationFormatter.string(from: summary.currentIncidentFreeDuration))
                        .font(.footnote.weight(.semibold))
                }
            }
            .foregroundStyle(.white.opacity(0.95))
        }
    }
}

struct FocusActivityCardItem: Identifiable {
    enum Summary {
        case progress(ProgressSummary)
        case decrease(DecreaseActivitySummary)
    }

    let activity: Activity
    let summary: Summary

    var id: UUID { activity.id }

    var accessibilitySummary: String {
        switch summary {
        case .progress(let progress):
            return "\(Int(progress.value)) of \(Int(progress.goal)) \(activity.measurement.displayName)"
        case .decrease(let summary):
            return "no incident recorded for \(DurationFormatter.string(from: summary.currentIncidentFreeDuration))"
        }
    }
}

#Preview {
    let preview = ActivitySummary.preview
    let focusItem = FocusActivityCardItem(
        activity: preview.activity,
        summary: .progress(preview.progress)
    )
    let reduceActivity = Activity(
        name: "Smoke",
        unitType: .count,
        goalValue: 1,
        createdAt: Date().addingTimeInterval(-2 * 24 * 60 * 60),
        type: .decrease
    )
    let reduceItem = FocusActivityCardItem(
        activity: reduceActivity,
        summary: .decrease(
            DecreaseActivityCalculator().calculate(
                activity: reduceActivity,
                observations: []
            )
        )
    )
    VStack {
        HStack {
            FocusCardView(item: focusItem, action: { })
            FocusCardView(item: reduceItem, action: { })
        }
    }
    .padding()
}
