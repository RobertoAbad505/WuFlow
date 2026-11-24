//
//  HomeView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/5/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var router: Router
    @Environment(\.repository) private var repository
    @State private var isPresentedAddProgress: Bool = false
    let progressCalculator: ProgressCalculator = .init()
    
    let insightEngine: InsightEngine = .init()
    private var insightStartDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: -30,
            to: .now
        ) ?? .distantPast
    }
    private var generalInsights: [Insight] {
        insightEngine.generalInsights(
            from: progressRecords,
            endingAt: insightStartDate
        )
    }
    
    @Query(
        sort: [
            SortDescriptor(\Activity.pinPriority, order: .reverse),
            SortDescriptor(\Activity.createdAt)
        ]
    )
    private var activities: [Activity]

    @Query(
        sort: \ProgressRecord.date,
        order: .reverse
    )
    private var progressRecords: [ProgressRecord]
    
    private let decreaseActivityCalculator = DecreaseActivityCalculator()

    private var focusCards: [FocusActivityCardItem] {
        activities.prefix(5).map { activity in
            if activity.type == .decrease {
                return FocusActivityCardItem(
                    activity: activity,
                    summary: .decrease(
                        decreaseActivityCalculator.calculate(
                            activity: activity,
                            observations: observations
                        )
                    )
                )
            }

            let records = progressRecords.filter {
                $0.activity.id == activity.id
            }
            let progress = progressCalculator.progress(
                for: activity,
                records: records
            )
            return FocusActivityCardItem(
                activity: activity,
                summary: .progress(progress)
            )
        }
    }
    
    @Query(sort: \ObservationRecord.date, order: .reverse)
    private var observations: [ObservationRecord]

    private var todaysProgressRecords: [ProgressRecord] {
        progressRecords.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var activitiesWithProgressToday: Int {
        Set(todaysProgressRecords.map(\.activity.id)).count
    }

    private var progressActivityDescription: String {
        let count = activitiesWithProgressToday
        return "Across \(count) \(count == 1 ? "activity" : "activities")"
    }

    private var decreaseActivities: [Activity] {
        activities.filter { $0.type == .decrease }
    }

    private var decreaseActivitiesWithIncidentsToday: Set<UUID> {
        Set(observations.compactMap { observation in
            guard observation.kind == .incident,
                  Calendar.current.isDateInToday(observation.date),
                  observation.activity.type == .decrease else {
                return nil
            }
            return observation.activity.id
        })
    }

    private var incidentFreeDecreaseActivityCount: Int {
        decreaseActivities.filter {
            !decreaseActivitiesWithIncidentsToday.contains($0.id)
        }.count
    }
    
    var body: some View {
        NavigationStack(path: $router.homePath) {
            ZStack {
                AppColors.canvas
                    .ignoresSafeArea()
                content
            }
            .navigationDestination(for: ActivitiesRoute.self) { route in
                switch route {
                case .activitiesList:
                    ActivityListView()
                case .detail(let activity):
                    ActivityDetailView(activity: activity)
                case .addActivity:
                    CreateActivityView(mode: .create)
                case .addProgress(let activity):
                    AddActivityProgressView(activity: activity)
                case .insights(_):
                    Text("Insights still in development")
                case .places:
                    PlacesListView()
                }
            }
            .sheet(isPresented: $isPresentedAddProgress) {
                AddActivityProgressView()
            }
        }
    }
    var content: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    HomeHeaderView()
                    dailySummarySection
                    focusSection
                    quickActionsSection
                    insightSection

                }
                .padding(16)
                .padding(.bottom, 60)
            }
            .background(alignment: .top) {
                Image("WuFlowHeaderImg")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: 260 + geometry.safeAreaInsets.top
                    )
                    .ignoresSafeArea(edges: .top)
            }
            .foregroundStyle(AppColors.midnightNavy)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
    var developmentTools: some View {
        VStack{
            Button(action: {
                guard let repository else { return }
                Task {
                    try? await repository.deleteMostRecentlyCreatedActivity()
                }
            }, label: {
                Text("Delete last activity and observations")
            })
        }
    }
    var dailySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's behavior")
                .font(.headline)
                .foregroundStyle(AppColors.midnightNavy)

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    overviewMetric(
                        value: "\(todaysProgressRecords.count)",
                        title: "Progress entries",
                        detail: progressActivityDescription
                    )

                    Rectangle()
                        .fill(AppColors.divider)
                        .frame(width: 1, height: 62)
                        .padding(.top, 4)

                    overviewMetric(
                        value: decreaseActivities.isEmpty
                            ? "—"
                            : "\(incidentFreeDecreaseActivityCount) / \(decreaseActivities.count)",
                        title: "No incident logged today",
                        detail: decreaseActivities.isEmpty
                            ? "No reduce activities yet"
                            : "Reduce activities"
                    )
                }

                Button {
                    router.homePath.append(ActivitiesRoute.activitiesList)
                } label: {
                    Label("View Activities", systemImage: "arrow.right")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.white)
                        .background(AppColors.midnightNavy, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.divider.opacity(0.8), lineWidth: 1)
            }
        }
    }

    private func overviewMetric(value: String, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppColors.midnightNavy)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.midnightNavy)

            Text(detail)
                .font(.footnote)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    var focusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Focus")
                    .font(.headline)
                Spacer()
                Button {
                    router.homePath.append(ActivitiesRoute.activitiesList)
                } label: {
                    Text("See all")
                        .font(.callout)
                        .foregroundStyle(AppColors.oceanBlue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(focusCards) { item in
                        FocusCardView(item: item) {
                            router.homePath.append(ActivitiesRoute.detail(item.activity))
                        }
                    }
                }
            }
        }
    }
    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Progress",
                    systemImage: "plus",
                    isPrimary: true) {
                    isPresentedAddProgress = true
                }
                QuickActionButton(
                    title: "New",
                    systemImage: "square.and.pencil",
                    isPrimary: false) {
                    print("Navigate to add activity view!!🚀 ")
                    router.homePath.append(ActivitiesRoute.addActivity)
                }
                QuickActionButton(
                    title: "Insights",
                    systemImage: "chart.bar",
                    isPrimary: false) {
                        print("Navigate to activity insights view!!🚀 ")
                    router.homePath.append(ActivitiesRoute.insights(nil))
                }
                QuickActionButton(
                    title: "Places",
                    systemImage: "pin",
                    isPrimary: false) {
                        print("Navigate to Places view!!🚀 ")
                    router.homePath.append(ActivitiesRoute.places)
                }
            }
        }
    }
    var insightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
                .foregroundStyle(AppColors.midnightNavy)
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
}
struct QuickActionButton: View {
    
    let title: String
    let systemImage: String
    let isPrimary: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(title)
                    .font(.footnote.weight(.medium))
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .background {
                if isPrimary {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppColors.midnightNavy)
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppColors.surface)
                }
            }
            .overlay {
                if !isPrimary {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppColors.divider, lineWidth: 1)
                }
            }
            .foregroundStyle(isPrimary ? Color.white : AppColors.midnightNavy)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let previewItems = [
        Activity(name: "GYM", unitType: .count, goalValue: 20, trackingType: .manual),
        Activity(name: "Meditation", unitType: .count, goalValue: 20, trackingType: .manual),
        Activity(name: "Push-ups", unitType: .count, goalValue: 20, trackingType: .manual)
    ]
    HomeView()
            .modelContainer(for: [Activity.self, ProgressRecord.self, ObservationRecord.self], inMemory: true) { result in
                if case let .success(container) = result {
                    let context = container.mainContext
                    previewItems.forEach { context.insert($0) }
                    try? context.save()
                }
            }
//            .modelContainer(for: ProgressRecord.self, inMemory: true)
    
}
