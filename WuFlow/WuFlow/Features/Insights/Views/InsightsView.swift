//
//  InsightsView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/7/26.
//
import SwiftUI
import SwiftData

struct InsightsView: View {
    
    @Environment(\.repository) private var repository

    @Query(sort: [
        SortDescriptor(\Activity.pinPriority, order: .reverse),
        SortDescriptor(\Activity.createdAt)
    ]) private var activities: [Activity]

    @Query(sort: \ProgressRecord.date, order: .reverse)
    private var progressRecords: [ProgressRecord]

    @Query(sort: \ObservationRecord.date, order: .reverse)
    private var observations: [ObservationRecord]

    @State private var selectedFilter: ActivityListFilter = .all
    @State private var isPresentingCreateActivity = false
    @State private var selectedToDelete: Activity?
    @State private var isShowingDeleteDialog = false

    private let progressCalculator = ProgressCalculator()
    private let decreaseCalculator = DecreaseActivityCalculator()
    private let milestoneCalculator = DecreaseMilestoneCalculator()
    private let streakCalculator = StreakCalculator()

    private var activityItems: [ActivityListItem] {
        activities.map { activity in
            if activity.type == .decrease {
                let summary = decreaseCalculator.calculate(
                    activity: activity,
                    observations: observations
                )
                let milestone = milestoneCalculator.progress(
                    currentDuration: summary.currentIncidentFreeDuration
                )
                return ActivityListItem(
                    activity: activity,
                    summary: .decrease(summary, milestone)
                )
            }

            let records = progressRecords.filter { $0.activity.id == activity.id }
            let progress = progressCalculator.progress(for: activity, records: records)
            return ActivityListItem(activity: activity, summary: .progress(progress))
        }
    }
    let insightEngine: InsightEngine = .init()
    private var generalInsights: [Insight] {
        insightEngine.generalInsights(
            from: progressRecords,
            endingAt: insightStartDate
        )
    }
    private var insightStartDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: -30,
            to: .now
        ) ?? .distantPast
    }

    private var visibleItems: [ActivityListItem] {
        switch selectedFilter {
        case .all:
            return activityItems
        case .inProgress:
            return activityItems.filter {
                if case .progress(let progress) = $0.summary {
                    return progress.status == .inProgress
                }
                return false
            }
        case .aboveGoal:
            return activityItems.filter {
                if case .progress(let progress) = $0.summary {
                    return progress.status == .exceeded
                }
                return false
            }
        case .incidentFree:
            return activityItems.filter { $0.activity.type == .decrease }
        }
    }

    private var globalStreak: Int {
        streakCalculator.globalStreak(records: progressRecords)
    }
    
    
    private var engine: InsightEngine = .init()
    
    @State private var selectedRange: InsightsHistoryRange = .last7Days
    
    var body: some View {
        VStack(spacing: 20) {
            header
            timePicker
            summaryPills
            Text("Still on development . . .")
                .foregroundStyle(AppColors.vermilion)
                .font(.title3.bold())
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.surface)
    }
    
    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Insights")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(AppColors.midnightNavy)
                Text("A new invitation to observe and be aware of yourself.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .padding(.trailing)
            WuWeiMark(size: 25)
        }
        .padding(.top, 8)
        .padding(.bottom, 14)
    }
    
    private var timePicker: some View {
        VStack {
            // Filter
            Picker("History range", selection: $selectedRange) {
                ForEach(InsightsHistoryRange.allCases) { range in
                    Text(range.title)
                        .tag(range)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedRange) { _, newValue in
                if newValue != .selectedMonth {
//                    displayedCalendarMonth = currentMonth
                }
            }
        }
    }
    private var summaryPills: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(spacing: 20) {
                getSquareInfo(
                    icon: "list.bullet",
                    value: "\(activities.count)",
                    label: "activities",
                    tint: AppColors.oceanBlue
                )
                getSquareInfo(
                    icon: "flame.fill",
                    value: "\(globalStreak)",
                    label: "day streak",
                    tint: AppColors.kinGold
                )
            }
            HStack(spacing: 20) {
                getSquareInfo(
                    icon: "checkmark.circle",
                    value: "\(count(for: .aboveGoal))",
                    label: "activities above goal",
                    tint: AppColors.oceanBlue
                )
                getSquareInfo(
                    icon: "clock",
                    value: "\(count(for: .inProgress))",
                    label: "activities in progress",
                    tint: AppColors.kinGold
                )
            }
            HStack(spacing: 20) {
                getSquareInfo(
                    icon: "checkmark.circle.fill",
                    value: "\(count(for: .incidentFree))",
                    label: "activities incident free",
                    tint: AppColors.oceanBlue
                )
                getSquareInfo(
                    icon: "flame.fill",
                    value: "\(count(for: .inProgress))",
                    label: "activities in progress",
                    tint: AppColors.kinGold
                )
            }
            
            
            
            ForEach(generalInsights) { insight in
                HStack(alignment: .center, spacing: 12) {
                    WuWeiMark(size: 22)

                    Rectangle()
                        .fill(AppColors.divider)
                        .frame(width: 1, height: 54)

                    HStack(alignment: .top, spacing: 10) {
//                        Image(systemName: "lightbulb.fill")
//                            .font(.title3)
//                            .foregroundStyle(AppColors.vermilion)
//                            .padding(.top, 1)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(insight.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.midnightNavy)
                            Text(insight.message)
                                .font(.footnote)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppColors.divider.opacity(0.8), lineWidth: 1)
                }
            }
            
            
        }
    }
    
    
    
    
    func getSquareInfo(icon: String, value: String, label: String, tint: Color) -> some View {
        return VStack {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 25))
                Text(value)
                    .font(.headline.bold())
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(label)
                .fixedSize(horizontal: false, vertical: true)
                .font(.body.bold())
        }
        .padding()
        .tint(tint)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 50))
    }

    private func summaryPill(icon: String, value: String, label: String, tint: Color) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppColors.midnightNavy)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: Capsule())
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ActivityListFilter.allCases) { filter in
                    let isSelected = selectedFilter == filter
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text("\(filter.rawValue) (\(count(for: filter)))")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isSelected ? AppColors.surface : AppColors.midnightNavy)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background {
                                Capsule()
                                    .fill(isSelected ? AppColors.midnightNavy : AppColors.surface.opacity(0.82))
                            }
                            .overlay {
                                Capsule().stroke(
                                    isSelected ? .clear : AppColors.divider,
                                    lineWidth: 1
                                )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.trailing, 2)
    }
    private func count(for filter: ActivityListFilter) -> Int {
        switch filter {
        case .all:
            return activityItems.count
        case .incidentFree:
            return activityItems.filter { $0.activity.type == .decrease }.count
        case .inProgress:
            return activityItems.filter {
                if case .progress(let progress) = $0.summary {
                    return progress.status == .inProgress
                }
                return false
            }.count
        case .aboveGoal:
            return activityItems.filter {
                if case .progress(let progress) = $0.summary {
                    return progress.status == .exceeded
                }
                return false
            }.count
        }
    }
}
#Preview {
    InsightsView()
}
