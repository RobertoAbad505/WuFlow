//
//  ActivityRowCard.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/14/26.
//
import SwiftUI

struct ActivityRowCard: View {
    
    private var color: Color {
        switch self.activity.status {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .exceeded: return .orange
        }
    }
    private var strokeColor: Color {
        switch self.activity.status {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .exceeded: return .green
        }
    }
    let activity: Activity
    
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: activity.iconName)
                        .font(.title)
                        .clipShape(Circle())
                        .symbolEffect(.rotate)
                    HStack(alignment: .bottom, spacing: 0) {
                        VStack(alignment: .leading){
                            Text(activity.name)
                                .font(.subheadline.bold())
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            unitTypeView
                        }
                        .frame(maxWidth: .infinity)
                        VStack(alignment: .trailing, spacing: 5) {
                            if activity.currentStreak > 1 {
                                StreakBadge(streak: activity.currentStreak)
                            }
                            ActivityStatusBadge(status: activity.status)
                        }
                        .frame(maxWidth: 100, alignment: .leading)
                    }
                    Image(systemName: "chevron.right")
                        .font(Font.system(size: 18))
                        .padding(.bottom, 5)
                }
                .padding(EdgeInsets(top: 15, leading: 10, bottom: 0, trailing: 10))
            }
            VStack(alignment: .center, spacing: 5) {
                ProgressView(value: activity.progressRatio)
                Text("\(activity.progressPercentage)%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 5)
            .background(strokeColor.opacity(0.20))
        }
        .cornerRadius(16)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
    }
    var unitTypeView: some View {
        HStack {
            Image(systemName: activity.unitType.iconName())
                .font(.system(size: 15).bold())
            Text("\(activity.todayProgress, specifier: "%.0f") / \(activity.goalValue, specifier: "%.0f")")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(activity.unitType.rawValue)
                .font(.caption)
        }
        .foregroundStyle(.gray)
    }
}


#Preview {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        ActivityRowCard(activity: Activity(name: "Missing Kaomi so much that I can't take it anymore",
                                           unitType: .pages,
                                           goalValue: 3,
                                           trackingType: .manual))
    }
    
}
