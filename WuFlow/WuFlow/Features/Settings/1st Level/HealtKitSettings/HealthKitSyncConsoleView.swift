//
//  HealthKitSyncConsoleView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 10/26/26.
//
import Foundation
import SwiftUI

/// On-demand HealthKit step synchronization for Settings > HealthKit Sync.
///
/// Requires HealthKitSyncService to expose isSyncing, completedDays,
/// totalDays, currentDay, errors, progress, and sync(days:calendar:).
struct HealthKitSyncConsoleView: View {
    @Environment(HealthKitSyncService.self) private var healthKit

    @State private var selectedPreset: SyncPreset = .custom
    @State private var startDate = Self.makeDate(year: 2026, month: 10, day: 1)
    @State private var endDate = Self.makeDate(year: 2026, month: 10, day: 26)
    @State private var syncTask: Task<Void, Never>?

    private let calendar = Calendar.current

    var body: some View {
        Form {
            Section {
                Picker("Period", selection: $selectedPreset) {
                    ForEach(SyncPreset.allCases) { preset in
                        Text(preset.title).tag(preset)
                    }
                }
                .disabled(healthKit.isSyncing)
                .onChange(of: selectedPreset) { _, newValue in
                    apply(newValue)
                }

                if selectedPreset == .custom {
                    DatePicker(
                        "Start date",
                        selection: $startDate,
                        displayedComponents: .date
                    )
                    .disabled(healthKit.isSyncing)

                    DatePicker(
                        "End date",
                        selection: $endDate,
                        in: startDate...,
                        displayedComponents: .date
                    )
                    .disabled(healthKit.isSyncing)
                }

                LabeledContent("Days to sync", value: "\(selectedDays.count)")
                LabeledContent("Date range", value: dateRangeDescription)
            } header: {
                Text("Select period")
            } footer: {
                Text("Custom ranges include both the start and end dates. Existing daily step records should be updated rather than duplicated.")
            }

            Section {
                if healthKit.isSyncing {
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressView(value: healthKit.progress)
                        Text("Processed \(healthKit.completedDays) of \(healthKit.totalDays) days")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let currentDay = healthKit.currentDay {
                            Text("Currently syncing \(currentDay.formatted(date: .long, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Button("Cancel Sync", role: .destructive) {
                            syncTask?.cancel()
                        }
                    }
                } else {
                    Button(action: startSync) {
                        Label("Sync Selected Period", systemImage: "arrow.clockwise")
                    }
                    .disabled(selectedDays.isEmpty || startDate > endDate)
                }

                if !healthKit.errors.isEmpty {
                    DisclosureGroup {
                        ForEach(Array(healthKit.errors.enumerated()), id: \.offset) { _, error in
                            Text(error)
                                .font(.caption)
                                .textSelection(.enabled)
                        }
                    } label: {
                        Label(
                            "\(healthKit.errors.count) day(s) failed",
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(.orange)
                    }
                } else if !healthKit.isSyncing && healthKit.completedDays > 0 {
                    Label("Sync finished without reported errors", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.subheadline)
                }
            } footer: {
                Text("Cancellation takes effect between daily queries; a query already in progress may finish first.")
            }
        }
        .navigationTitle("HealthKit Sync")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var selectedDays: [Date] {
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        guard start <= end else { return [] }

        var dates: [Date] = []
        var day = start

        while day <= end {
            dates.append(day)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else {
                break
            }
            day = nextDay
        }
        return dates
    }

    private var dateRangeDescription: String {
        guard !selectedDays.isEmpty else { return "Invalid range" }

        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(
            from: calendar.startOfDay(for: startDate),
            to: calendar.startOfDay(for: endDate)
        )
    }

    private func apply(_ preset: SyncPreset) {
        let today = calendar.startOfDay(for: .now)

        switch preset {
        case .today:
            startDate = today
            endDate = today
        case .yesterday:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
            startDate = yesterday
            endDate = yesterday
        case .last7Days:
            startDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today
            endDate = today
        case .last30Days:
            startDate = calendar.date(byAdding: .day, value: -29, to: today) ?? today
            endDate = today
        case .custom:
            break
        }
    }

    private func startSync() {
        guard !healthKit.isSyncing else { return }
        let days = selectedDays
        guard !days.isEmpty else { return }

        syncTask = Task {
            await healthKit.sync(days: days, calendar: calendar)
        }
    }

    private static func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = .current
        components.year = year
        components.month = month
        components.day = day
        return components.date ?? .now
    }
}

private enum SyncPreset: String, CaseIterable, Identifiable {
    case today
    case yesterday
    case last7Days
    case last30Days
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .yesterday: return "Yesterday"
        case .last7Days: return "Last 7 Days"
        case .last30Days: return "Last 30 Days"
        case .custom: return "Custom Range"
        }
    }
}


#Preview {
    HealthKitSyncConsoleView()
}
