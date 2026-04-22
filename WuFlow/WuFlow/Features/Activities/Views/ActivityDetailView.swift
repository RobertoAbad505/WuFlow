//
//  ActivityDetailView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import SwiftUI
import SwiftData
import Charts

struct ActivityDetailView: View {
    
    @Query var records: [ProgressRecord] = []
    
    @State var presentAddProgress: Bool = false
    @State var selectedFilter: TimeFilter = .today
    
    let activity: Activity
    
    var numberFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    var goalFeedback: String {
        switch goalStatus {
        case .inProgress:
            return "Keep going — you're making progress."
        case .completed:
            return "Goal reached 🎉"
        case .exceeded:
            return "Amazing — you went beyond your goal 🚀"
        }
    }
    var goalStatus: GoalStatus {
        if todayProgress >= activity.goalValue {
            if todayProgress > activity.goalValue {
                return .exceeded
            } else {
                return .completed
            }
        } else {
            return .inProgress
        }
    }
    //todayProgress value
    var todayProgress: Double {
        let calendar = Calendar.current
        
        let todayRecords = records.filter { record in
            calendar.isDateInToday(record.date)
        }
        
        return todayRecords.reduce(0) { partial, record in
            partial + record.value
        }
    }
    var filteredRecords: [ProgressRecord] {
        ProgressAnalytics.filterRecords(records, by: selectedFilter)
    }

    var groupedData: [Date: Double] {
        ProgressAnalytics.groupByDay(filteredRecords)
    }

    var chartData: [DailyProgress] {
        ProgressAnalytics.makeChartData(from: groupedData)
    }
    var progressRatio: Double {
        min(todayProgress / activity.goalValue, 1.0)
    }
    
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
    var body: some View {
        VStack(alignment: .center, spacing: 30){
            ZStack {
                AnimatedBackgroundView(style: .calm)
                    .ignoresSafeArea()
                scrollView
            }
        }
        .sheet(isPresented: $presentAddProgress, content: {
            AddActivityProgressView(activity: self.activity)
        })
        .onAppear {
            print("Records count: OnAppear", records.count)
        }
    }
    
    
    var scrollView: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                inspoSection
                infoData
                addProgressSection
                Divider()
                Text("Progress records")
                    .font(.headline)
                filterSelection
                chartProgressView
                progressRecordsView
            }
            .padding()
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 30))
            .padding()
        }
    }
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 25) {
                    activityImage
                    VStack(alignment: .leading, spacing: 5) {
                        Text(activity.name + " details")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("\(todayProgress, specifier: "%.0f") / \(activity.goalValue, specifier: "%.0f") \(activity.unitType.rawValue)")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                VStack {
                    Text(goalFeedback)
                        .font(.subheadline)
                        .foregroundColor(.green)
                    ProgressView(value: progressRatio)
                        .tint(Color.colorForActivity(self.activity))
                }
                .padding(.bottom)
            }
        }
        .containerShape(RoundedRectangle(cornerRadius: 30))
    }
    var inspoSection: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                if let motivationDescription = activity.motivationDescription {
                    Text("Here's some motivation from your self")
                        .font(.headline)
                    Text(motivationDescription )
                        .font(.body)
                }
                if let expectedOutcome = activity.expectedOutcome {
                    Text("Remember what you are expecting")
                        .font(.headline)
                    Text(expectedOutcome )
                        .font(.body)
                }
            }
            .padding()
        }
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 30))
    }
    var infoData: some View {
        VStack {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 0) {
                        Image(systemName: "pin")
                        Text("Tracking \(activity.trackingType.rawValue)")
                    }
                    Divider()
                    HStack(alignment: .top, spacing: 0) {
                        Image(systemName: "pin")
                        Text("Goal \(numberFormat.string(from: NSNumber(value: activity.goalValue))!) \(activity.unitType.rawValue)")
                    }
                }
                .padding()
                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
                Spacer()
                VStack {
                    HStack(alignment: .top, spacing: 5) {
                        Image(systemName: "flame")
                            .symbolEffect(.breathe)
                            .foregroundStyle(Color.red)
                        Text("Current streak: \(activity.currentStreak, specifier: "%.0f")")
                    }
                    Divider()
                    HStack(alignment: .top, spacing: 5) {
                        Image(systemName: "flame")
                            .symbolEffect(.breathe)
                            .foregroundStyle(Color.red)
                        Text("Longest streak: \(activity.longestStreak, specifier: "%.0f")")
                    }
                }
                .padding()
                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 30))
            }
            .font(.system(size: 14))
            .padding(.bottom, 20)
            HStack(alignment: .top, spacing: 0) {
                Image(systemName: "calendar")
                Text("Created by \(activity.createdAt, format: .dateTime.month().year())")
                    .font(.system(size: 12))
                Spacer()
            }
        }
    }
    var addProgressSection: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Button(action: {
                    presentAddProgress.toggle()
                }, label: {
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(Font.system(size: 20))
                        Text("Add new progress!")
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.green)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.white)
                })
                .clipShape(RoundedRectangle(cornerRadius: 25))
                Spacer()
            }
        }
    }
    var filterSelection: some View {
        VStack {
            HStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TimeFilter.allCases, id: \.self) { filter in
                        Text(title(for: filter)).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
    var chartProgressView: some View {
        VStack {
            Chart(chartData) { item in
                BarMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Progress", item.total)
                )
                .foregroundStyle(.blue)
                .annotation(position: .top) {
                    Text("\(item.total, specifier: "%.0f")")
                        .font(.caption)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .animation(.easeInOut, value: chartData)
            .frame(height: 300)
        }
    }
    var progressRecordsView: some View {
        VStack{
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(filteredRecords) { record in
                    HStack {
                        Text("+\(record.value, specifier: "%.0f") \(self.activity.unitType.rawValue)")
                        Spacer()
                        Text(record.date, format: .dateTime.day().month().year())
                    }
                    .padding()
                    .glassEffect()
                }
            }
            if filteredRecords.count > 0 {
                Text("Filtered count: \(filteredRecords.count)")
                    .font(Font.body.bold())
            }
        }
    }
    var activityImage: some View {
        VStack {
            if let data = activity.imageData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .frame(width: 120, height: 150)
            } else {
                Image(systemName: activity.iconName ?? "circle.dotted")
                    .font(.system(size: 35))
            }
        }
    }
    func title(for filter: TimeFilter) -> String {
        switch filter {
        case .all: return "All"
        case .today: return "Today"
        case .yesterday: return "Yesterday"
        case .currentWeek: return "Week"
        case .lastWeek: return "Last Week"
        case .currentMonth: return "Month"
        case .lastMonth: return "Last Month"
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
                                          expectedOutcome: "We want to relax at the beach without mental noise, just be there and be present"
                                         ))
    .modelContainer(for: Activity.self, inMemory: false)
    .modelContainer(for: ProgressRecord.self, inMemory: true)
}
