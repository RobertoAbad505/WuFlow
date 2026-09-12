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
    @Environment(\.modelContext) var modelContext
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
    
    var focusCards: [ActivitySummary] {
        Array(activitySummaries.prefix(5))
    }
    private var activitySummaries: [ActivitySummary] {
        activities.map { activity in

            let records = progressRecords.filter {
                $0.activity.id == activity.id
            }

            let progress = progressCalculator.progress(
                for: activity,
                records: records
            )

            return ActivitySummary(
                activity: activity,
                progress: progress
            )
        }
    }
    
    private var totalActivities: Int {
        activitySummaries.count
    }

    private var completedActivities: Int {
        activitySummaries.count(where: \.progress.completed)
    }

    private var progressRatio: Double {
        guard totalActivities > 0 else {
            return 0
        }
        return Double(completedActivities) / Double(totalActivities)
    }
    
    var progressMessage: String {
        switch progressRatio {
        case 0:
            return "Start your day with a small action"
        case 0..<0.5:
            return "You're getting started"
        case 0..<1:
            return "You're building momentum"
        default:
            return "Great job — you're on fire 🔥"
        }
    }
    
    var body: some View {
        NavigationStack(path: $router.homePath) {
            ZStack {
                Image("plantBackground")
                    .resizable()
                    .ignoresSafeArea()
                    .blur(radius: 3)
                Color.black.opacity(0.1)
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
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                HomeHeaderView()
                dailySummarySection
                focusSection
                quickActionsSection
                insightSection
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    var dailySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                
                // Title + message
                VStack(alignment: .leading, spacing: 4) {
                    Text("Build your momentum")
                        .font(.title3.bold())
                    
                    Text(progressMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Progress + ring
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(completedActivities) / \(totalActivities)")
                            .font(.title2.bold())
                        Text("Goals completed!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button {
                            isPresentedAddProgress = true
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Progress")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                    }
                    Spacer()
                    ProgressRingView(progress: progressRatio)
                }
            }
            .padding(15)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
        }
        .padding(15)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))
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
                        .foregroundColor(.secondary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(focusCards) { item in
                        FocusCardView(item: item) {
                            router.homePath.append(ActivitiesRoute.detail(item.activity))
                        }
                        .onAppear {
                            print("Rendering: \(item.activity.name)")
                        }
                    }
                }
            }
        }
        .padding()
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))
    }
    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Add",
                    systemImage: "plus",
                    tint: .green) {
                    isPresentedAddProgress = true
                }
                QuickActionButton(
                    title: "New",
                    systemImage: "square.and.pencil",
                    tint: .blue) {
                    print("Navigate to add activity view!!🚀 ")
                    router.homePath.append(ActivitiesRoute.addActivity)
                }
                QuickActionButton(
                    title: "Insights",
                    systemImage: "chart.bar",
                    tint: .purple) {
                        print("Navigate to activity insights view!!🚀 ")
                    router.homePath.append(ActivitiesRoute.insights(nil))
                }
                QuickActionButton(
                    title: "Places",
                    systemImage: "pin",
                    tint: .purple) {
                        print("Navigate to Places view!!🚀 ")
                    router.homePath.append(ActivitiesRoute.places)
                }
            }
        }
        .padding()
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))
    }
    var insightSection: some View {
        VStack {
            Text("Insights")
                .font(.headline)
                .bold(true)
            ForEach(generalInsights) { insight in
                InsightRow(icon: "lightbulb.fill",
                           color: .yellow,
                           title: insight.title,
                           subtitle: insight.message)
            }
        }
        .padding()
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))
    }
}
struct QuickActionButton: View {
    
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
struct ProgressRingView: View {
    
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption.bold())
        }
        .frame(width: 70, height: 70)
    }
}
#Preview {
    let previewItems = [
        Activity(name: "GYM", unitType: .count, goalValue: 20, trackingType: .manual),
        Activity(name: "Meditation", unitType: .count, goalValue: 20, trackingType: .manual),
        Activity(name: "Push-ups", unitType: .count, goalValue: 20, trackingType: .manual)
    ]
    HomeView()
            .modelContainer(for: Activity.self, inMemory: true) { result in
                if case let .success(container) = result {
                    let context = container.mainContext
                    previewItems.forEach { context.insert($0) }
                    try? context.save()
                }
            }
//            .modelContainer(for: ProgressRecord.self, inMemory: true)
    
}
