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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.repository) private var repository
    @Environment(HealthKitSyncService.self)
    private var healthKit
    @Query var records: [ProgressRecord] = []
    @Query var observations: [ObservationRecord] = []
    @Query var sessions: [PlaceSession]
    
    private var activeSession: PlaceSession? {
        sessions.first(where: \.isActive)
    }
    private var expectedSessionDuration: TimeInterval? {
        SessionDurationCalculator().expectedDuration(from: sessions)
    }
    
    @State private var activeSheet: ActiveDetailsSheet?
    
    private let insightEngine = InsightEngine()
    private let activity: Activity
    @State private var showDeleteDialog = false
    @State private var displayedCalendarMonth: Date = {
        Calendar.current.startOfMonth(for: Date())
    }()
    
    // MARK: - Computed
    @State private var selectedRange: ActivityHistoryRange = .last7Days
    private var selectedDateRange: DateInterval? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        switch selectedRange {
        case .last7Days:
            guard let start = calendar.date(
                byAdding: .day,
                value: -6,
                to: today
            ),
            let end = calendar.date(
                byAdding: .day,
                value: 1,
                to: today
            ) else {
                return nil
            }

            return DateInterval(start: start, end: end)

        case .last30Days:
            guard let start = calendar.date(
                byAdding: .day,
                value: -29,
                to: today
            ),
            let end = calendar.date(
                byAdding: .day,
                value: 1,
                to: today
            ) else {
                return nil
            }

            return DateInterval(start: start, end: end)

        case .selectedMonth:
            return calendar.dateInterval(
                of: .month,
                for: displayedCalendarMonth
            )
        }
    }

    private var filteredRecords: [ProgressRecord] {
        guard let range = selectedDateRange else {
            return []
        }

        return records.filter {
            $0.date >= range.start && $0.date < range.end
        }
    }

    private var filteredObservations: [ObservationRecord] {
        guard let range = selectedDateRange else {
            return []
        }

        return observations.filter {
            $0.date >= range.start && $0.date < range.end
        }
    }
    private var groupedRecordsByDay: [(date: Date, records: [ProgressRecord])] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: filteredRecords) {
            calendar.startOfDay(for: $0.date)
        }

        return grouped
            .map { (date: $0.key, records: $0.value) }
            .sorted { $0.date > $1.date }
    }

    private var groupedData: [Date: Double] {
        ProgressAnalytics.groupByDay(filteredRecords)
    }

    private var chartData: [DailyProgress] {
        ProgressAnalytics.makeChartData(from: groupedData)
    }

    private var activeDaysLast7: Int {
        ActivityInsights.activeDaysLast7(records: records)
    }
    private var isPresentingImage: Bool {
        return !(activity.imagePath == nil || (activity.imagePath ?? "").isEmpty)
    }
    private var backgroundStyle: BackgroundStyle {
        switch activity.type {
        case .increase: return .growth
        case .maintain: return .flow
        case .decrease: return .reduce
        }
    }
    private var progress: ProgressSummary {
        progressCalculator.progress(
            for: activity,
            records: records
        )
    }
    
    private let progressCalculator: ProgressCalculator = .init()
    
    //Decrease calculator
    private let decreaseActivityCalculator = DecreaseActivityCalculator()

    private var decreaseSummary: DecreaseActivitySummary {
        decreaseActivityCalculator.calculate(
            activity: activity,
            observations: observations
        )
    }
    //Streak calc
    private let streakCalculator = StreakCalculator()

    private var streakCount: Int {
        streakCalculator.activityStreak(
            activity,
            records: records
        )
    }
    private var insights: [Insight] {
        insightEngine.insights(
            for: activity,
            sessions: sessions
        )
    }
    //Delete observation
    @State private var isShowingDeleteObservationDialog: Bool = false
    @State private var selectedObservationToDelete: ObservationRecord?
    //---------------------------------------------------------------
    @State private var selectedObservationImage: ObservationRecord?
    @State private var selectedObservation: ObservationRecord?
    @State private var selectedBehaviorDay: BehaviorDay?
    @State private var placeSession: PlaceSession?
    
    private var currentMonth: Date {
        behaviorCalendarCalendar.startOfMonth(
            for: Date()
        )
    }
    private var canGoNextCalendarMonth: Bool {
        displayedCalendarMonth < currentMonth
    }
    private var behaviorCalendarCalendar: Calendar {
        Calendar.current
    }
    private var displayedMonthRange: DateInterval? {
        behaviorCalendarCalendar.dateInterval(
            of: .month,
            for: displayedCalendarMonth
        )
    }
    private var behaviorCalendarData: BehaviorCalendarData? {
        guard let range = displayedMonthRange else {
            return nil
        }

        return behaviorCalendarDataCalculator.calculate(
            progressRecords: filteredRecords,
            observations: filteredObservations,
            from: range.start,
            to: range.end,
            calendar: behaviorCalendarCalendar
        )
    }
    private let behaviorCalendarDataCalculator =
        BehaviorCalendarDataCalculator()
    private var isCurrentCalendarMonth: Bool {
        displayedCalendarMonth == currentMonth
    }
    // MARK: - Init
    
    init(activity: Activity) {
        self.activity = activity

        let activityID = activity.id

        _records = Query(
            filter: #Predicate<ProgressRecord> { record in
                record.activity.id == activityID
            },
            sort: \.date,
            order: .reverse
        )

        _observations = Query(
            filter: #Predicate<ObservationRecord> { observation in
                observation.activity.id == activityID
            },
            sort: \.date,
            order: .reverse
        )
        _sessions = Query(
                filter: #Predicate<PlaceSession> { session in
                    session.activity?.id == activityID
                },
                sort: \.startedAt,
                order: .reverse
            )
    }
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(style: backgroundStyle)
                .ignoresSafeArea()
            content
        }
        .toolbar {
            activityToolbar
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addProgress:
                AddActivityProgressView(activity: activity)

            case .editActivity:
                CreateActivityView(mode: .edit(activity))

            case .activityReminders:
                ReminderSettingsView(activity: activity)

            case .createObservation:
                AddObservationView(activity: activity) { newObservation in
                    
                    guard let repository, let newObservation else {
                        return
                    }
                    Task {
                        do{
                            let observation = try await repository.createObservation(newObservation, activity)
                            print("✅ Observation saved:", observation.id)
                            print("Activity:", observation.activity.name)
                            print("New observation👀 created!")
                        } catch let error {
                            print("Error creating observation: \(error.localizedDescription)")
                        }
                    }
                }
                .onDisappear {
                    self.activeSheet = nil
                    print("Dismissed create observation")
                }
            }
        }
        .sheet(item: $selectedBehaviorDay) { day in
            BehaviorDayDetailView(
                day: day,
                mode: activity.type == .decrease
                    ? .incidents
                    : .progress
            )
        }
        .fullScreenCover(item: $selectedObservationImage) { observation in
            ObservationImageViewer(observation: observation)
        }
        .confirmationDialog(
            "Delete observation?",
            isPresented: $isShowingDeleteObservationDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let observation = selectedObservationToDelete {
                    deleteObservation(observation)
                }
            }
            Button("Cancel", role: .cancel) { selectedObservationToDelete = nil }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    private func deleteObservation(_ observation: ObservationRecord) {
        Task {
            guard let repository else { return }
            do {
                try await repository.deleteObservation(id: observation.id)
            } catch {
                print("Unable to delete activity:", error)
            }
            selectedObservationToDelete = nil
        }
    }
    
    @ToolbarContentBuilder
    private var activityToolbar: some ToolbarContent {

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                activeSheet = .editActivity
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 20))
                    .tint(activity.remindersEnabled ? .green : .gray)
            }
            .buttonStyle(.glass)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                setPinnedActivity()
            } label: {
                Image(systemName: activity.isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 20))
                    .tint(.green)
            }
            .buttonStyle(.glass)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                enableNotifications()
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .tint(activity.remindersEnabled ? .green : .gray)
            }
            .buttonStyle(.glass)
        }

        if activity.remindersEnabled {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    activeSheet = .activityReminders
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .tint(.green)
                }
                .buttonStyle(.glass)
            }
        }
    }

    var content: some View {
        ScrollView {
            activityImage
            VStack {
                VStack(spacing: 24) {
                    if let activeSession {
                        ActiveSessionCard(
                            session: activeSession,
                            expectedDuration: expectedSessionDuration
                        )
                    }
                    heroSection
                    observationsSection
                    trackingSection
                    meaningSection
                    insightsSection
                    calendarComponentSection
                    behavioralHistorySection
                    deleteButton
                }
                .padding()
                .offset(y: isPresentingImage ? -150:0)
                .offset(y: activeSession == nil ? 0: -50)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
extension ActivityDetailView {
    var observationsSection: some View {
        Group {
            if !observations.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Observations")
                        .font(.headline)

                    LazyVStack(spacing: 20) {
                        ForEach(observations) { observation in
                            ActivityObservationView(observation: observation) {
                                guard observation.imagePath?.isEmpty == false else { return }
                                selectedObservationImage = observation
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    selectedObservationToDelete = observation
                                    isShowingDeleteObservationDialog = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.regularMaterial)
                )
            }
        }
    }
    
    @ViewBuilder
    var heroSection: some View {
        switch activity.type {
        case .increase, .maintain:
            progressHeroSection

        case .decrease:
            decreaseHeroSection
        }
    }
    var progressHeroSection: some View {
        VStack(spacing: 15) {
            identity

            VStack(spacing: 15) {
                ProgressView(value: progress.ratio)
                    .tint(Color.colorForActivity(activity))
                    .animation(.easeInOut, value: progress.ratio)

                Text(progress.description(activity.measurement))
                    .font(.headline)

                Text(feedbackMessage())
                    .font(.subheadline)
                    .foregroundColor(colorForStatus)
                    .multilineTextAlignment(.center)
            }
            .padding(.leading)

            heroButtons
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.regularMaterial)
        )
        .cornerRadius(20)
    }
    var decreaseHeroSection: some View {
        VStack(spacing: 20) {

            identity

            VStack(spacing: 8) {
                Text(DurationFormatter.string(
                    from: decreaseSummary.currentIncidentFreeDuration
                ))
                .font(.system(size: 40, weight: .bold))

                Text("since your last incident")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {

                DecreaseMetric(
                    value: "\(decreaseSummary.incidentCount)",
                    title: "Incidents",
                    icon: "exclamationmark.circle"
                )

                DecreaseMetric(
                    value: DurationFormatter.string(from: decreaseSummary.awarenessDuration),
                    title: "Awareness",
                    icon: "eye"
                )
            }
            decreaseHeroButtons
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.regularMaterial)
        )
        .cornerRadius(20)
    }
    @ViewBuilder
    var decreaseHeroButtons: some View {
        VStack {
            addObservationButton
        }
    }
    var heroButtons: some View {
        VStack {
            if activity.trackingType != .healthSteps {
                Button {
                    self.activeSheet = .addProgress
                } label: {
                    Label("Log progress", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.midnightNavy)
                        .foregroundStyle(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            observationActionButton
            if activity.isAutomated && activity.trackingType == .healthSteps {
                Button {
                    healthKit.sync()
                } label: {
                    Label("Sync Apple Health",
                          systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle")
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.mistBlue.opacity(0.6))
                        .foregroundStyle(AppColors.oceanBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    var identity: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(activity.name)
                .font(.title2)
                .fontWeight(.bold)
            Text(activity.goalDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(activity.goalPeriod.displayName)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    private var observationActionButton: some View {
        Button {
            activeSheet = .createObservation
        } label: {
            Label(
                activity.type == .decrease ? "Record observation" : "Add note",
                systemImage: "plus.circle"
            )
            .font(.subheadline.weight(.medium))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(AppColors.surface.opacity(0.8))
            .foregroundStyle(AppColors.midnightNavy)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColors.divider, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var addObservationButton: some View {
        observationActionButton
    }
    
//    @ViewBuilder
//    var addObservationButton: some View {
//       //Create observation
//       Button(action: {
//           print("Create observation triggered!")
//           self.activeSheet = .createObservation
//       }, label: {
//           Label("Add observation ☯️👀", systemImage: "plus.circle")
//           .font(.headline)
//           .padding(.vertical, 12)
//           .frame(maxWidth: .infinity)
//           .background(Color.green)
//           .foregroundColor(.white)
//           .clipShape(RoundedRectangle(cornerRadius: 16))
//       })
//    }
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
    @ViewBuilder
    var insightsSection: some View {
        switch activity.type {
        case .increase, .maintain:
            progressInsightsSection
        case .decrease:
            decreasePatternsSection
        }
    }
    var progressInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Your patterns")
                .font(.headline)
            
            ForEach(insights) { insight in
                InsightRow(icon: "lightbulb.fill",
                           color: .black,
                           title: insight.title,
                           subtitle: insight.message)
            }
            VStack(spacing: 12) {
                
                InsightRow(
                    icon: "flame.fill",
                    color: .red,
                    title: StreakFormatter.title(
                        count: streakCount,
                        period: activity.goalPeriod
                    ),
                    subtitle: StreakFormatter.message(for: streakCount)
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
    var decreasePatternsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your patterns")
                .font(.headline)
            
            Text("\(decreaseSummary.incidentCount) Incidents")

            DecreaseMetric(
                value: DurationFormatter.string(
                    from: decreaseSummary.longestIncidentFreeDuration
                ),
                title: "Longest incident-free",
                icon: "chart.line.uptrend.xyaxis"
            )
            if let average = decreaseSummary.averageIncidentInterval {
                DecreaseMetric(
                    value: DurationFormatter.string(from: average),
                    title: "Average time between incidents",
                    icon: "arrow.left.arrow.right"
                )
            }
            DecreaseMetric(
                value: "\(decreaseSummary.incidentCount)",
                title: "Incidents recorded",
                icon: "exclamationmark.circle"
            )
            DecreaseMetric(
                value: DurationFormatter.string(
                    from: decreaseSummary.currentIncidentFreeDuration
                ),
                title: decreaseIncidentFreeDurationTitle,
                icon: "clock"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.regularMaterial)
        )
    }
    var decreaseIncidentFreeDurationTitle: String {
        return decreaseSummary.incidentCount == 0
        ? "Since you started"
        : "Since last incident"
    }
    func streakMessage(_ streakCount: Int) -> String {
        switch streakCount {
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
    var averageText: String {
        let totals = groupedData.values
        guard !totals.isEmpty else { return "No data yet" }
        
        let avg = totals.reduce(0, +) / Double(totals.count)
        
        return "\(Int(avg)) \(activity.unitType.rawValue)"
    }
    @ViewBuilder
    var behavioralHistorySection: some View {
        switch activity.type {
        case .increase, .maintain:
            VStack(spacing: 24) {
                chartSection
                recordsSection
            }

        case .decrease:
            decreaseHistorySection
        }
    }
    var calendarComponentSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Behavior history")
                    .font(.headline)
                Spacer()
                if !isCurrentCalendarMonth {
                    Button("Today") {
                        displayedCalendarMonth = currentMonth
                        selectedRange = .selectedMonth
                    }
                    .font(.caption)
                }
            }
            behaviorCalendarSection
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.regularMaterial)
        )
    }
    private func showPreviousCalendarMonth() {
        guard let previousMonth = behaviorCalendarCalendar.date(
            byAdding: .month,
            value: -1,
            to: displayedCalendarMonth
        ) else {
            return
        }

        displayedCalendarMonth = previousMonth
        selectedRange = .selectedMonth
    }

    private func showNextCalendarMonth() {
        guard canGoNextCalendarMonth,
              let nextMonth = behaviorCalendarCalendar.date(
                  byAdding: .month,
                  value: 1,
                  to: displayedCalendarMonth
              ) else {
            return
        }

        displayedCalendarMonth = nextMonth
        selectedRange = .selectedMonth
    }
    @ViewBuilder
    private var behaviorCalendarSection: some View {
        if let calendarData = behaviorCalendarData {
            VStack(alignment: .leading) {
                CalendarMonthHeader(
                    month: displayedCalendarMonth,
                    calendar: behaviorCalendarCalendar,
                    onPrevious: showPreviousCalendarMonth,
                    onNext: showNextCalendarMonth,
                    canGoNext: canGoNextCalendarMonth)
                BehaviorCalendar(
                    positions: calendarData.positions,
                    calendar: behaviorCalendarCalendar,
                    mode: activity.type == .decrease
                        ? .incidents
                    : .progress,
                    onDaySelected: { day in
                        selectedBehaviorDay = day
                    }
                )
            }
        }
    }
    var decreaseHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Incident history")
                .font(.headline)

            let incidents = observations.filter {
                $0.kind == .incident
            }

            if incidents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 30))
                        .foregroundStyle(.secondary)

                    Text("No incidents recorded")
                        .font(.headline)

                    Text("Keep observing. You can record an incident whenever it happens.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            } else {
                VStack(spacing: 0) {
                    ForEach(incidents) { observation in
                        DecreaseIncidentRow(observation: observation)
                            .onTapGesture {
                                selectedObservation = observation
                            }
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
            Picker("History range", selection: $selectedRange) {
                ForEach(ActivityHistoryRange.allCases) { range in
                    Text(range.title)
                        .tag(range)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedRange) { _, newValue in
                if newValue != .selectedMonth {
                    displayedCalendarMonth = currentMonth
                }
            }
            
            // Chart
            Chart {
                ForEach(chartData) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Progress", item.total)
                    )
                    .foregroundStyle(barColor(for: item))
                }

                RuleMark(y: .value("Goal", activity.goalValue))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(.gray.opacity(0.6))
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
        VStack(alignment: .leading, spacing: 16) {

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

            trackingDetails
            if let place = activity.place {
                LocationMapView(place: place)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.regularMaterial)
        )
    }
    @ViewBuilder
    private var trackingDetails: some View {
        switch activity.trackingType {
        case .location:
            if let place = activity.place {
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    LabeledContent("Place") {
                        Text(place.name)
                    }
                    LabeledContent("Radius") {
                        Text("\(Int(place.radius)) m")
                    }
                }
                .font(.subheadline)
            }
        default:
            EmptyView()
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
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .frame(width: 10, height: 10)
                        Text("\(groupedRecordsByDay.count) records found")
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

            ActivityImageView(
                path: activity.imagePath,
                icon: activity.iconName
            )
            .frame(maxHeight: 600)
            .frame(maxWidth: .infinity)
//            .allowsHitTesting(false)
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
        Task {
            guard let repository else { return }
            do {
                try await repository.deleteActivity(id: activity.id)
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                dismiss()
            } catch let error {
                print("❌ Delete activity failed:", error)
                print("activity name: \(activity.name)")
                print("error.localizedDescription:", error)
            }
        }
    }
    private func enableNotifications() {
        Task {
            guard let repository else { return }
            do {
                try await repository.enableNotifications(id: activity.id)                
                if self.activity.remindersEnabled {
                    NotificationManager.shared.scheduleReminder(for: self.activity)
                    print("Notifications enabled and scheduled")
                } else {
                    NotificationManager.shared.cancelReminder(for: activity)
                    print("Notifications disabled and cleared schedule")
                }
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            } catch let error {
                print("❌ Enable notifications failed:", error)
            }
        }
    }
    private func setPinnedActivity() {
        Task {
            guard let repository else { return }
            print("Pinned: \(activity.isPinned ? "enabled" : "disabled") order: \(activity.pinPriority)")
            do {
                try await repository.togglePinned(id: activity.id)
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
        switch progress.status {
        case .inProgress: return .green
        case .completed: return .blue
        case .exceeded: return .purple
        case .notStarted: return .gray
        }
    }
    func feedbackMessage() -> String {
        switch progress.status {
        case .inProgress:
            if progress.ratio == 0 {
                return "Start small today 🌱"
            } else if progress.ratio < 0.5 {
                return "You're building momentum"
            } else {
                return "You're almost there"
            }
        case .completed:
            return "Goal reached 🎉"
        case .exceeded:
            return "You exceeded your goal 🚀"
        case .notStarted:
            return "Not started"
        }
    }
}
private enum ActiveDetailsSheet: Identifiable {
    case addProgress
    case editActivity
    case activityReminders
    case createObservation

    var id: Self { self }
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
                                              imagePath: path,
                                              remindersEnabled: true,
                                              isPinned: true
                                             ))
        .modelContainer(for: Activity.self, inMemory: false)
        .modelContainer(for: ProgressRecord.self, inMemory: true)
    }
}
