//
//  HomeView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/5/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var activities: [Activity]
    @State private var isPresentedAddProgress: Bool = false
    @State private var path = NavigationPath()
    
    var totalActivities: Int {
        activities.count
    }

    var completedToday: Int {
        activities.filter { $0.isCompletedToday }.count
    }

    var progressRatio: Double {
        guard totalActivities > 0 else { return 0 }
        return Double(completedToday) / Double(totalActivities)
    }
    var focusActivities: [Activity] {
        Array(activities.prefix(4))
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Image("plantBackground")
                    .resizable()
                    .ignoresSafeArea()
                    .blur(radius: 1)
                content
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .activityList:
                    ActivityListView()
                case .activityDetail(let activity):
                    ActivityDetailView(activity: activity)
                case .addActivity:
                    CreateActivityView(mode: .create)
                case .addProgress(let activity):
                    AddActivityProgressView(activity: activity)
                case .insights:
                    InsightsView()
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
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    var dailySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                
                // Title + message
                VStack(alignment: .leading, spacing: 4) {
                    Text("Build your momentum")
                        .font(.title3.bold())
                    
                    Text(summaryMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Progress + ring
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(completedToday) / \(totalActivities)")
                            .font(.title2.bold())
                        Text("Activities completed today")
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
    var summaryMessage: String {
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
    var focusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Text("Your Focus")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    path.append(AppRoute.activityList)
                } label: {
                    Text("See all")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(focusActivities) { activity in
                        FocusCardView(activity: activity) {
                            path.append(AppRoute.activityDetail(activity))
                        }
                    }
                }
            }
            .padding(15)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
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
                    tint: .green
                ) {
                    isPresentedAddProgress = true
                }
                
                QuickActionButton(
                    title: "New",
                    systemImage: "square.and.pencil",
                    tint: .blue
                ) {
                    path.append(AppRoute.addActivity)
                }
                
                QuickActionButton(
                    title: "Insights",
                    systemImage: "chart.bar",
                    tint: .purple
                ) {
                    path.append(AppRoute.insights)
                }
            }
        }
        .padding()
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24))
    }
//    func calculateGlobalStreak() -> Int {
//        let calendar = Calendar.current
//        
//        var streak = 0
//        var date = Date()
//        
//        while true {
//            let hasProgress = self.activities.contains { activity in
//                activity.progressRecords.contains {
//                    calendar.isDate($0.date, inSameDayAs: date)
//                }
//            }
//            
//            if hasProgress {
//                streak += 1
//                date = calendar.date(byAdding: .day, value: -1, to: date)!
//            } else {
//                break
//            }
//        }
//        
//        return streak
//    }
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
struct InsightsView: View {
    var body: some View {
        Text("Insights coming soon")
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
    HomeView()
        .modelContainer(for: Activity.self, inMemory: false)
}
