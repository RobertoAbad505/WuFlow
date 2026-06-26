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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query var records: [ProgressRecord] = []
    
    @State var presentAddProgress: Bool = false
    @State var presentEditProcess: Bool = false
    @State var presentRemindersProcess: Bool = false
    
    let activity: Activity
    @State private var selectedFilter: TimeFilter = .last7Days
    @State private var showDeleteDialog = false
    
    // MARK: - Computed
    var filteredRecords: [ProgressRecord] {
        guard let range = selectedFilter.dateRange() else {
            return records
        }
        
        return records.filter {
            $0.date >= range.start && $0.date <= range.end
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

    var groupedData: [Date: Double] {
        ProgressAnalytics.groupByDay(filteredRecords)
    }
    var chartData: [DailyProgress] {
        ProgressAnalytics.makeChartData(from: groupedData)
    }

    var activeDaysLast7: Int {
        ActivityInsights.activeDaysLast7(records: records)
    }
    var isPresentingImage: Bool {
        return !(activity.imagePath == nil || (activity.imagePath ?? "").isEmpty)
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
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(style: .calm)
                .ignoresSafeArea()
            content
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    print("Enable notifications: \(activity.remindersEnabled ? "off":"on")")
                    enableNotifications()
                }, label: {
                    Image(systemName: "bell")
                        .font(Font.system(size: 20))
                        .tint(activity.remindersEnabled ? .green: .gray)
                })
                .buttonStyle(.glass)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    presentEditProcess = true
                }, label: {
                    Image(systemName: "pencil")
                        .font(Font.system(size: 20))
                        .tint(activity.remindersEnabled ? .green: .gray)
                })
                .buttonStyle(.glass)
            }
            if activity.remindersEnabled {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentRemindersProcess.toggle()
                    }, label: {
                        Image(systemName: "calendar")
                            .font(Font.system(size: 20))
                            .tint(.green)
                    })
                    .buttonStyle(.glass)
                }
            }
        })
        .sheet(isPresented: $presentAddProgress) {
            AddActivityProgressView(activity: activity)
        }
        .sheet(isPresented: $presentRemindersProcess) {
            ReminderSettingsView(activity: activity)
        }
        .fullScreenCover(isPresented: $presentEditProcess) {
            CreateActivityView(mode: .edit(self.activity))
        }
    }
    var content: some View {
        ScrollView {
            activityImage
            VStack {
                VStack(spacing: 24) {
                    heroSection
                    trackingSection
                    meaningSection
                    insightsSection
                    chartSection
                    recordsSection
                    deleteButton
                }
                .padding()
                .offset(y: !isPresentingImage ? 0: -150)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}
extension ActivityDetailView {
    
    var heroSection: some View {
        VStack(spacing: 15) {
            // Identity
            identity
            
            // Progress value
            VStack(spacing: 15) {
                ProgressView(value: activity.progressRatio)
                    .tint(Color.colorForActivity(activity))
                    .animation(.easeInOut, value: activity.progressRatio)
                Text(activity.progressDescription)
                    .font(.headline)
                // Feedback (THIS is the key)
                Text(activity.feedbackMessage)
                    .font(.subheadline)
                    .foregroundColor(colorForStatus)
                    .multilineTextAlignment(.center)
            }
            .padding(.leading)
            
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
                .fill(.regularMaterial)
        )
        .cornerRadius(20)
    }
    var identity: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(activity.name)
                .font(.title2)
                .fontWeight(.bold)
            Text(activity.goalDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(activity.periodDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    var meaningSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if hasMeaningContent {
                Text("Why this matters")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 15) {
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
                .fill(.regularMaterial)
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
                    subtitle: activity.streakMessage
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
                .fill(.regularMaterial)
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
                .fill(.regularMaterial)
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
    //tracking Section
    private var trackingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tracking Method")
                .font(.headline)
            HStack(spacing: 16) {
                Image(systemName: activity.trackingType.icon)
                    .font(.title2)
                    .foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.trackingType.title)
                        .font(.headline)
                    Text(activity.trackingType.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.regularMaterial)
        )
        .cornerRadius(20)
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
                .fill(.regularMaterial)
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
    var activityImage: some View {
        VStack(spacing: 0) {
            if !isPresentingImage {
                Spacer(minLength: 190)
            }
            ActivityImageView(path: activity.imagePath, icon: activity.iconName)
                .frame(maxHeight: 600)
                .id(activity.imagePath)
        }
    }
    
    var deleteButton: some View {
        HStack {
            Image(systemName: "trash")
                .font(.system(size: 30))
                .foregroundStyle(.white)
            VStack(alignment: .leading) {
                Text("Delete this activity")
                    .font(.system(size: 14, weight: .bold))
                Text("Stop tracking this efforts, this action is irreversible")
                    .font(.system(size: 12, weight: .none))
            }
            Spacer()
            Button(action: {
                showDeleteDialog = true
            }) {
                HStack {
                    Text("Delete")
                    Image(systemName: "trash")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 10)
                .background(Color.red)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 2)
            }
        }
        .padding()
        .background(Color.red.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 2)
        }
        .padding(.vertical)
        .padding(.bottom, 50)
        .confirmationDialog(
            "Delete Activity?",
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                delete()
            }
            Button("Cancel", role: .cancel) {
                showDeleteDialog = false
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    private func delete() {
        withAnimation {
            modelContext.delete(self.activity)
            
            do {
                try modelContext.save()
            } catch {
                print("❌ Delete failed:", error)
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        dismiss()
    }
    private func enableNotifications() {
        withAnimation {
            self.activity.remindersEnabled.toggle()
            if self.activity.remindersEnabled {
                NotificationManager.shared.scheduleReminder(for: self.activity)
                print("Notifications enabled and scheduled")
            } else {
                NotificationManager.shared.cancelReminder(for: activity)
                print("Notifications disabled and cleared schedule")
            }
            
            do {
                try modelContext.save()
            } catch {
                print("❌ Enable notifications failed:", error)
            }
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()            
        }
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
    var colorForStatus: Color {
        switch activity.goalStatus {
        case .inProgress: return .green
        case .completed: return .blue
        case .exceeded: return .purple
        }
    }
}

#Preview {
    let path = try? ImageStore.shared.save(UIImage(named: "activityImg") ?? UIImage(),
                                           category: .activity)
    NavigationStack {
        ActivityDetailView(activity: Activity(name: "Meditation",
                                              unitType: .sessions,
                                              goalValue: 3,
                                              trackingType: .healthSteps,
                                              iconName: "circle.dotted",
                                              motivationDescription: "Remember always is a great time to meditate",
                                              expectedOutcomeDescription: "We want to relax at the beach without mental noise, just be there and be present",
                                              imagePath: path))
        .modelContainer(for: Activity.self, inMemory: false)
        .modelContainer(for: ProgressRecord.self, inMemory: true)
    }
}
