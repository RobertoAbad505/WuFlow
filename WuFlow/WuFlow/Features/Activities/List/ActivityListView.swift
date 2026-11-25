//
//  ActivityListView.swift
//  WuFlow
//

import SwiftUI
import SwiftData
import UIKit

enum ActivityListFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case inProgress = "In progress"
    case aboveGoal = "Above goal"
    case incidentFree = "Incident-free"

    var id: String { rawValue }
}

struct ActivityListView: View {
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

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                AppColors.canvas.ignoresSafeArea()

                Image("WuFlowHeaderImg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width,
                           height: 238 + geometry.safeAreaInsets.top,
                           alignment: .top)
                    .clipped()
                    .ignoresSafeArea(edges: .top)

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        summaryPills
                        filters
                        activityList
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .fullScreenCover(isPresented: $isPresentingCreateActivity) {
            CreateActivityView(mode: .create)
        }
        .navigationDestination(for: Activity.self) { activity in
            ActivityDetailView(activity: activity)
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        .confirmationDialog(
            "Delete activity?",
            isPresented: $isShowingDeleteDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let activity = selectedToDelete {
                    delete(activity)
                }
            }
            Button("Cancel", role: .cancel) { selectedToDelete = nil }
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear(perform: {
            NotificationManager.shared.syncReminders(for: self.activities)
        })
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activities")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(AppColors.midnightNavy)
                Text("A steady practice, at your pace.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer(minLength: 8)
            WuWeiMark(size: 30)

#if DEBUG
            Menu {
                Button("Print pending notifications", systemImage: "bell.badge") {
                    NotificationManager.shared.printPendingNotifications()
                }
                Button("Resync notifications", systemImage: "arrow.clockwise") {
                    NotificationManager.shared.syncReminders(for: activities)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColors.midnightNavy)
                    .frame(width: 40, height: 40)
                    .background(.regularMaterial, in: Circle())
            }
#endif

            Button {
                isPresentingCreateActivity = true
            } label: {
                Image(systemName: "plus")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColors.surface)
                    .frame(width: 44, height: 44)
                    .background(AppColors.midnightNavy, in: Circle())
            }
            .accessibilityLabel("Create activity")
        }
        .padding(.top, 8)
        .padding(.bottom, 14)
    }

    private var summaryPills: some View {
        HStack(spacing: 10) {
            summaryPill(
                icon: "list.bullet",
                value: "\(activities.count)",
                label: "activities",
                tint: AppColors.oceanBlue
            )
            summaryPill(
                icon: "flame.fill",
                value: "\(globalStreak)",
                label: "day streak",
                tint: AppColors.kinGold
            )
        }
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

    private var activityList: some View {
        LazyVStack(spacing: 12) {
            if visibleItems.isEmpty {
                ContentUnavailableView(
                    selectedFilter == .all ? "No activities yet" : "No matching activities",
                    systemImage: "circle.dashed",
                    description: Text(selectedFilter == .all
                                      ? "Create an activity to begin your practice."
                                      : "Try another filter to see your activities.")
                )
                .padding(.top, 36)
            } else {
                ForEach(visibleItems) { item in
                    NavigationLink(value: item.activity) {
                        ActivityRowCard(item: item)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            selectedToDelete = item.activity
                            isShowingDeleteDialog = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            pinActivity(item.activity)
                        } label: {
                            Label(
                                item.activity.isPinned ? "Unpin" : "Pin",
                                systemImage: item.activity.isPinned ? "pin.slash" : "pin"
                            )
                        }
                    }
                }
                EndPageView()
            }
        }
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

    private func pinActivity(_ activity: Activity) {
        Task {
            guard let repository else { return }
            do {
                try await repository.togglePinned(id: activity.id)
            } catch {
                print("Unable to update pinned activity:", error)
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    private func delete(_ activity: Activity) {
        Task {
            guard let repository else { return }
            do {
                try await repository.deleteActivity(id: activity.id)
            } catch {
                print("Unable to delete activity:", error)
            }
            selectedToDelete = nil
        }
    }
}
