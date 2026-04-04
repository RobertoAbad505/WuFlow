//
//  ActivityDetailView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/3/26.
//

import SwiftUI
import SwiftData

struct ActivityDetailView: View {
    var numberFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
        
    @Query var records: [ProgressRecord] = []
    
    @State var presentAddProgress: Bool = false
    
    let activity: Activity
    
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
            Text("Progress records:")
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(records) { record in
                    HStack {
                        Text("+\(record.value, specifier: "%.0f")")
                        Spacer()
                        Text(record.date, style: .time)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    func getTodaysProgress() {
        
    }
}

#Preview {
    ActivityDetailView(activity: Activity(name: "Meditation",
                                          unitType: .sessions,
                                          goalValue: 3,
                                          trackingType: .manual))
}
