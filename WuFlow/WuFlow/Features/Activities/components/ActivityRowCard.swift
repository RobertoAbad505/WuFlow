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
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                HStack(alignment: .center ,spacing: 12) {
                    activityImage
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
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
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
        VStack {
            HStack {
                Image(systemName: activity.unitType.iconName())
                    .font(.system(size: 18).bold())
                VStack {
                    Text("\(activity.todayProgress, specifier: "%.0f") / \(activity.goalValue, specifier: "%.0f")")
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
        VStack {
            if let data = activity.imageData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .frame(width: 100, height: 120)
            } else {
                Image(systemName: activity.iconName ?? "circle.dotted")
                    .font(.system(size: 25))
            }
        }
    }
}


#Preview {
    ZStack {
        Color.gray.opacity(0.4).ignoresSafeArea()
        ActivityRowCard(activity: Activity(name: "Missing Kaomi so much that I can't take it anymore",
                                           unitType: .pages,
                                           goalValue: 3,
                                           trackingType: .manual))
    }
    
}
