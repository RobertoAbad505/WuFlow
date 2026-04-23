//
//  ActivityDetailView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import SwiftUI
import SwiftData
import Charts
import SwiftUI
import SwiftData

struct ActivityDetailView: View {
    
    @Query var records: [ProgressRecord] = []
    
    @State var presentAddProgress: Bool = false
    
    let activity: Activity
    @State private var selectedFilter: TimeFilter = .last7Days
    
    // MARK: - Computed
    var filteredRecords: [ProgressRecord] {
        guard let range = selectedFilter.dateRange() else {
            return records
        }
        
        return records.filter {
            $0.date >= range.start && $0.date <= range.end
        }
    }

    var groupedData: [Date: Double] {
        ProgressAnalytics.groupByDay(filteredRecords)
    }
    var chartData: [DailyProgress] {
        ProgressAnalytics.makeChartData(from: groupedData)
    }
    
    var todayProgress: Double {
        let calendar = Calendar.current
        
        let todayRecords = records.filter {
            calendar.isDateInToday($0.date)
        }
        
        return todayRecords.reduce(0) { $0 + $1.value }
    }
    
    var progressRatio: Double {
        guard activity.goalValue > 0 else { return 0 }
        return min(todayProgress / activity.goalValue, 1.0)
    }
    
    var progressPercentage: Int {
        Int(progressRatio * 100)
    }
    
    var goalStatus: GoalStatus {
        if todayProgress >= activity.goalValue {
            return todayProgress > activity.goalValue ? .exceeded : .completed
        } else {
            return .inProgress
        }
    }
    
    var activeDaysLast7: Int {
        ActivityInsights.activeDaysLast7(records: records)
    }
    
    var feedbackMessage: String {
        switch goalStatus {
        case .inProgress:
            if progressRatio == 0 {
                return "Start small today 🌱"
            } else if progressRatio < 0.5 {
                return "You're building momentum"
            } else {
                return "You're almost there"
            }
        case .completed:
            return "Goal reached 🎉"
        case .exceeded:
            return "You exceeded your goal 🚀"
        }
    }
    var streakMessage: String {
        switch activity.currentStreak {
        case 0:
            return "Start your streak today"
        case 1...2:
            return "You're getting started"
        case 3...6:
            return "You're building consistency"
        default:
            return "You're on fire 🔥"
        }
    }
    
    
    // MARK: - Init
    
    init(activity: Activity) {
        self.activity = activity
        
        let activityID = activity.id
        
        _records = Query(
            filter: #Predicate<ProgressRecord> { record in
                record.activity?.id == activityID
            },
            sort: \.date,
            order: .reverse
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(style: .calm)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    heroSection
                    meaningSection
                    insightsSection
                    chartSection
                    recordsSection
                }
                .padding()
            }
        }
        .sheet(isPresented: $presentAddProgress) {
            AddActivityProgressView(activity: activity)
        }
    }
}
extension ActivityDetailView {
    
    var heroSection: some View {
        VStack(spacing: 20) {
            
            // Identity
            HStack(spacing: 16) {
                activityImage
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(progressPercentage)% complete today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Progress value
            VStack(spacing: 8) {
                Text("\(todayProgress, specifier: "%.0f") / \(activity.goalValue, specifier: "%.0f") \(activity.unitType.rawValue)")
                    .font(.headline)
                
                ProgressView(value: progressRatio)
                    .tint(Color.colorForActivity(activity))
                    .animation(.easeInOut, value: progressRatio)
            }
            
            // Feedback (THIS is the key)
            Text(feedbackMessage)
                .font(.subheadline)
                .foregroundColor(colorForStatus)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
            
            // CTA (important positioning)
            Button {
                presentAddProgress.toggle()
            } label: {
                Label("Add progress", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        )
    }
}
extension ActivityDetailView {
    
    var activityImage: some View {
        Group {
            if let data = activity.imageData,
               let img = UIImage(data: data) {
                
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                
            } else {
                Image(systemName: activity.iconName ?? "circle.dotted")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 70, height: 70)
        .background(.ultraThinMaterial)
        .clipShape(Circle())
        .symbolEffect(.pulse, value: activity.iconName)
    }
    
    var colorForStatus: Color {
        switch goalStatus {
        case .inProgress: return .green
        case .completed: return .blue
        case .exceeded: return .purple
        }
    }
}
extension ActivityDetailView {
    
    var meaningSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            if hasMeaningContent {
                
                Text("Why this matters")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    if let motivation = activity.motivationDescription,
                       !motivation.isEmpty {
                        
                        MeaningBlock(
                            icon: "leaf.fill",
                            title: "Your reason",
                            text: motivation,
                            color: .green
                        )
                    }
                    
                    if let outcome = activity.expectedOutcomeDescription,
                       !outcome.isEmpty {
                        
                        MeaningBlock(
                            icon: "target",
                            title: "What you're aiming for",
                            text: outcome,
                            color: .blue
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        )
    }
}
extension ActivityDetailView {
    
    var hasMeaningContent: Bool {
        let hasMotivation = !(activity.motivationDescription?.isEmpty ?? true)
        let hasOutcome = !(activity.expectedOutcomeDescription?.isEmpty ?? true)
        return hasMotivation || hasOutcome
    }
    var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Your patterns")
                .font(.headline)
            
            VStack(spacing: 12) {
                
                InsightRow(
                    icon: "flame.fill",
                    color: .red,
                    title: "\(activity.currentStreak) day streak",
                    subtitle: streakMessage
                )
                
                InsightRow(
                    icon: "calendar",
                    color: .blue,
                    title: "\(activeDaysLast7) active days",
                    subtitle: "In the last 7 days"
                )
                
                InsightRow(
                    icon: "chart.bar.fill",
                    color: .green,
                    title: averageText,
                    subtitle: "Your daily average"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        )
    }
    var averageText: String {
        let totals = groupedData.values
        guard !totals.isEmpty else { return "No data yet" }
        
        let avg = totals.reduce(0, +) / Double(totals.count)
        
        return "\(Int(avg)) \(activity.unitType.rawValue)"
    }
    //chart sections
    var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Progress over time")
                    .font(.headline)
                
                Text(chartInsight)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Filter
            Picker("", selection: $selectedFilter) {
                Text("7D").tag(TimeFilter.last7Days)
                Text("30D").tag(TimeFilter.last30Days)
                Text("All").tag(TimeFilter.all)
            }
            .pickerStyle(.segmented)
            
            // Chart
            Chart(chartData) { item in
                
                BarMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Progress", item.total)
                )
                .foregroundStyle(barColor(for: item))
                
                // Optional value label
                .annotation(position: .top) {
                    Text("\(Int(item.total))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                RuleMark(y: .value("Goal", activity.goalValue))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundStyle(Color.gray.opacity(0.6))
                .annotation(position: .topTrailing) {
                    Text("Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(minHeight: 300)
            .animation(.easeInOut, value: chartData)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        )
    }
    var chartInsight: String {
        guard chartData.count > 1 else {
            return "Start tracking to see your progress"
        }
        
        let first = chartData.first?.total ?? 0
        let last = chartData.last?.total ?? 0
        
        if last > first {
            return "You're improving over time 📈"
        } else if last == first {
            return "You're staying consistent"
        } else {
            return "Your activity has slowed down"
        }
    }
    var groupedRecordsByDay: [(date: Date, records: [ProgressRecord])] {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: filteredRecords) {
            calendar.startOfDay(for: $0.date)
        }
        
        return grouped
            .map { ($0.key, $0.value) }
            .sorted { $0.date > $1.date }
    }
    func barColor(for item: DailyProgress) -> Color {
        guard let index = chartData.firstIndex(where: { $0.date == item.date }),
              index > 0 else {
            return Color.colorForActivity(activity)
        }
        
        let previous = chartData[index - 1].total
        
        if item.total > previous {
            return .green
        } else if item.total < previous {
            return .red.opacity(0.7)
        } else {
            return .gray
        }
    }
    
    //Records section
    var recordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Your activity timeline")
                .font(.headline)
            
            if groupedRecordsByDay.isEmpty {
                emptyState
            } else {
                VStack(spacing: 16) {
                    ForEach(groupedRecordsByDay, id: \.date) { group in
                        DayGroupView(
                            date: group.date,
                            records: group.records,
                            unit: activity.unitType.rawValue
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        )
    }
    var emptyState: some View {
        VStack(spacing: 12) {
            
            Image(systemName: "sparkles")
                .font(.system(size: 30))
                .foregroundColor(.secondary)
                .symbolEffect(.pulse)
            
            Text("No activity yet")
                .font(.headline)
            
            Text("Start tracking to see your progress")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
struct MeaningBlock: View {
    
    let icon: String
    let title: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            Image(systemName: icon)
                .foregroundColor(color)
                .symbolEffect(.pulse, value: text)
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(text)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}
struct InsightRow: View {
    
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            
            Image(systemName: icon)
                .foregroundColor(color)
                .symbolEffect(.pulse)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
struct DayGroupView: View {
    
    let date: Date
    let records: [ProgressRecord]
    let unit: String
    
    var total: Double {
        records.reduce(0) { $0 + $1.value }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // Header (date + total)
            HStack {
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(total)) \(unit)")
                    .font(.headline)
            }
            
            // Entries
            VStack(spacing: 6) {
                ForEach(records) { record in
                    HStack {
                        Text("+\(Int(record.value))")
                            .font(.body)
                        
                        Spacer()
                        
                        Text(record.date, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
    
    var formattedDate: String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

#Preview {
    ActivityDetailView(activity: Activity(name: "Meditation",
                                          unitType: .sessions,
                                          goalValue: 3,
                                          trackingType: .manual,
                                          iconName: "circle.dotted",
                                          motivationDescription: "Remember always is a great time to meditate",
                                          expectedOutcomeDescription: "We want to relax at the beach without mental noise, just be there and be present"
                                         ))
    .modelContainer(for: Activity.self, inMemory: false)
    .modelContainer(for: ProgressRecord.self, inMemory: true)
}
