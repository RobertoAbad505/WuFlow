//
//  ActivityRowCard.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/14/26.
//
import SwiftUI

struct ActivityRowCard: View {
    
    private var color: Color {
        switch self.progress.status {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .exceeded: return .orange
        }
    }
    private var strokeColor: Color {
        switch self.progress.status {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .exceeded: return .green
        }
    }
    
    private var activity: Activity {
        summary.activity
    }

    private var progress: ProgressSummary {
        summary.progress
    }
    var streakCount: Int {
        let streakCalc = StreakCalculator()
        return streakCalc.activityStreak(summary.activity,
                                         records: summary.progress.records)
    }
    
    let summary: ActivitySummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center ,spacing: 10) {
                activityImage
                VStack {
                    HStack(alignment: .center, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0){
                            Text(activity.name)
                                .font(.subheadline.bold())
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            unitTypeView
                        }
                        .frame(maxWidth: .infinity)
                        badgesItems
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 18))
                            .padding(.bottom, 5)
                    }
                    VStack(alignment: .center, spacing: 5) {
                        ProgressView(value: progress.ratio)
                        Text("\(progress.percentage)%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 5)
                }
                .padding()
            }
            .background(.ultraThinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    if activity.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 16))
                            .rotationEffect(.degrees(45))
                            .tint(.secondary.opacity(0.55))
                    }
                }
                .padding(12)
                Spacer()
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white, lineWidth: 1)
        }
    }
    var badgesItems: some View {
        VStack(alignment: .trailing, spacing: 5) {
            if streakCount > 1 {
                StreakBadge(streak: streakCount)
            }

            ActivityStatusBadge(status: progress.status)
        }
    }
    var unitTypeView: some View {
        VStack {
            HStack {
                Image(systemName: activity.unitType.iconName())
                    .font(.system(size: 18).bold())
                VStack {
                    Text(progress.description(activity.measurement))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(activity.unitType.rawValue)
                        .font(.caption)
                }
            }
        }
        .foregroundStyle(.gray)
        .padding(.top, 3)
    }
    var activityImage: some View {
        ActivityImageView(path: activity.imagePath, icon: activity.iconName)
            .frame(maxWidth: 100, maxHeight: 100)
    }
}


#Preview {
    let activity = Activity(
        name: "Missing Kaomi so much that I can't take it anymore",
        unitType: .pages,
        goalValue: 3,
        trackingType: .manual,
        isPinned: true
    )

    let progress = ProgressCalculator().progress(
        for: activity,
        records: []
    )

    let summary = ActivitySummary(
        activity: activity,
        progress: progress
    )

    ZStack {
        Image("zengarden")
            .resizable()
            .ignoresSafeArea()

        VStack(alignment: .center, spacing: 20) {
            ActivityRowCard(summary: .preview)
            ActivityRowCard(summary: .preview)
            ActivityRowCard(summary: summary)
            ActivityRowCard(summary: summary)
            ActivityRowCard(summary: summary)
        }
        .padding()
    }
}
