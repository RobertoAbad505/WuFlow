//
//  ActivityRowCard.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/14/26.
//
import SwiftUI

struct ActivityRowCard: View {
    
    let activity: Activity
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: activity.iconName)
                    .font(.title2)
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
                    .symbolEffect(.rotate)
                
                VStack(alignment: .center, spacing: 6) {
                    HStack {
                        VStack(alignment: .leading){
                            Text(activity.name)
                                .font(.subheadline.bold())
                                .foregroundStyle(.black)
                            unitTypeView
                        }
                        Spacer()
                        VStack {
                            if activity.currentStreak > 1 {
                                StreakBadge(streak: activity.currentStreak)
                            }
                            ActivityStatusBadge(status: activity.status)
                        }
                    }
                }
                Spacer()
            }
            ProgressView(value: activity.progressRatio)
            Text("\(activity.progressPercentage)%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
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
struct StreakBadge: View {
    let streak: Int
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("🔥 \(streak) day" + (streak > 1 ? "s":""))
                    .font(.system(size: 12).bold())
                    .foregroundStyle(.white)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 13)
            .background(.gray)
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(.white, lineWidth: 1)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        ActivityRowCard(activity: Activity(name: "Meditation",
                                           unitType: .pages,
                                           goalValue: 3,
                                           trackingType: .manual))
    }
    
}
