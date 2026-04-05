//
//  ActivityDetailView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import SwiftUI
import SwiftData

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
    var goalMessage: String {
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
            Text(activity.name + " \nDetails")
                .font(.title)
            scrollView
        }
        .padding()
        .padding(.horizontal, 25)
        .sheet(isPresented: $presentAddProgress, content: {
            AddActivityProgressView(
                activity: self.activity,
                onDismiss: {
                    print("Records count:After save", records.count)
                    withAnimation {
                        presentAddProgress = false
                    }
            })
        })
        .onAppear {
            print("Records count: OnAppear", records.count)
        }
    }
    var scrollView: some View {
        ScrollView(.vertical) {
            HStack {
                Text("Unit type: \n\(activity.unitType.rawValue)")
                    .font(.title)
                Spacer()
                Text("Goal:\n\(numberFormat.string(from: NSNumber(value: activity.goalValue))!)")
                    .font(.title)
            }
            VStack(alignment: .center, spacing: 10) {
                Text("Today: \(todayProgress, specifier: "%.0f") / \(activity.goalValue, specifier: "%.0f") \(activity.unitType.rawValue)")
                Text(goalMessage)
                    .font(.headline)
                    .foregroundColor(.green)
            }
            HStack {
                Text("Tracking type:\n\(activity.trackingType.rawValue)")
                    .font(.title)
                Spacer()
                Text("Created at \n\n\(activity.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    .font(.title)
            }
            HStack {
                Spacer()
                Text("Records:\n\(activity.progressRecords.count)")
                    .font(.title)
                Spacer()
            }
            Button(action: {
                presentAddProgress.toggle()
            }, label: {
                VStack {
                    Text("➕")
                    Text("Add progress!")
                }
                .padding(10)
                .background(.green)
                .buttonBorderShape(.roundedRectangle)
            })
            Divider()
            Text("Today's activity")
            HStack {
                Text("\(activity.goalValue, specifier: "%.0f")")
                Text("\(activity.unitType.rawValue)")
            }
            Divider()
            Text("Progress records")
                .font(.headline)
            Text("Quick filters:")
                .font(.subheadline)
            Picker("Filter", selection: $selectedFilter) {
                ForEach(TimeFilter.allCases, id: \.self) { filter in
                    Text(title(for: filter)).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            Text("Filtered count: \(filteredRecords.count)")
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(filteredRecords) { record in
                    HStack {
                        Text("+\(record.value, specifier: "%.0f")")
                        Spacer()
                        Text(record.date, format: .dateTime.day().month())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
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
                                          trackingType: .manual))
}
