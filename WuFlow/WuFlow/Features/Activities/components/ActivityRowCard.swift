import SwiftUI

struct ActivityListItem: Identifiable {
    enum Summary {
        case progress(ProgressSummary)
        case decrease(DecreaseActivitySummary, DecreaseMilestoneProgress)
    }

    let activity: Activity
    let summary: Summary

    var id: UUID { activity.id }
}

struct ActivityRowCard: View {
    let item: ActivityListItem

    private var activity: Activity { item.activity }

    var body: some View {
        HStack(spacing: 12) {
            activityThumbnail

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 8) {
                    Text(activity.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.midnightNavy)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    statusBadge
                }

                summaryContent
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.divider.opacity(0.85), lineWidth: 1)
                .overlay(alignment: .leading) {
                    if case .progress(let progress) = item.summary,
                       progress.status == .exceeded {
                        Capsule()
                            .fill(AppColors.kinGold)
                            .frame(width: 3)
                            .padding(.vertical, 14)
                    }
                }
        }
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var activityThumbnail: some View {
        ZStack {
            AppColors.mistBlue.opacity(0.55)

            if activity.imagePath != nil {
                ActivityImageView(
                    path: activity.imagePath,
                    icon: activity.iconName,
                    contentMode: .fill
                )
            } else {
                Image(systemName: activity.iconName ?? "circle.dotted")
                    .font(.system(size: 23, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.oceanBlue)
            }
        }
        .frame(width: 54, height: 54)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppColors.divider.opacity(0.65), lineWidth: 1)
        }
        .overlay(alignment: .topTrailing) {
            if activity.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 8, weight: .semibold))
                    .rotationEffect(.degrees(45))
                    .foregroundStyle(AppColors.midnightNavy)
                    .padding(3)
                    .background(AppColors.surface, in: Circle())
                    .offset(x: 3, y: -3)
            }
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch item.summary {
        case .progress(let progress):
            ActivityStatusBadge(status: progress.status)

        case .decrease(let summary, _):
            Label(
                "Incident-free · \(DurationFormatter.string(from: summary.currentIncidentFreeDuration))",
                systemImage: "checkmark.circle.fill"
            )
            .font(.caption2.weight(.medium))
            .lineLimit(1)
            .foregroundStyle(AppColors.matchaSage)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(AppColors.matchaSage.opacity(0.12), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppColors.matchaSage.opacity(0.28), lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private var summaryContent: some View {
        switch item.summary {
        case .progress(let progress):
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(progress.description(activity.measurement))
                        .font(.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    if progress.status == .inProgress || progress.status == .notStarted {
                        Text("\(progress.percentage)%")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

                ProgressView(value: progress.ratio)
                    .tint(progressColor(for: progress.status))
            }

        case .decrease(_, let milestone):
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text("Next milestone: \(milestone.targetLabel)")
                        .font(.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                    Spacer(minLength: 0)
                    Text("\(milestone.percentage)%")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppColors.secondaryText)
                }

                ProgressView(value: milestone.progress)
                    .tint(AppColors.matchaSage)
            }
        }
    }

    private func progressColor(for status: ActivityStatus) -> Color {
        switch status {
        case .notStarted:
            return AppColors.mistBlue
        case .inProgress:
            return AppColors.oceanBlue
        case .completed:
            return AppColors.midnightNavy
        case .exceeded:
            return AppColors.kinGold
        }
    }
}

#Preview {
    let activity = Activity(
        name: "Smoke",
        unitType: .count,
        goalValue: 1,
        createdAt: Date().addingTimeInterval(-2 * 24 * 60 * 60),
        type: .decrease
    )
    let decreaseSummary = DecreaseActivityCalculator().calculate(
        activity: activity,
        observations: []
    )
    let item = ActivityListItem(
        activity: activity,
        summary: .decrease(
            decreaseSummary,
            DecreaseMilestoneCalculator().progress(
                currentDuration: decreaseSummary.currentIncidentFreeDuration
            )
        )
    )

    ActivityRowCard(item: item)
        .padding()
        .background(AppColors.canvas)
}
