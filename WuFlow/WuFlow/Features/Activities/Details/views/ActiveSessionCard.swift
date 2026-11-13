//
//  ActiveSessionCard.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 11/13/26.
//



import SwiftUI

struct ActiveSessionCard: View {
    let session: PlaceSession
    let expectedDuration: TimeInterval?
    private let progressCalculator = SessionProgressCalculator()

    var body: some View {
        if session.isActive {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                VStack {
                    HStack(spacing: 14) {

                        Image(systemName: session.icon ?? "figure.run")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .background(.white.opacity(0.15), in: Circle())

                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 7, height: 7)

                                Text("SESSION IN PROGRESS")
                                    .font(.caption2.weight(.semibold))
                                    .tracking(0.7)
                                    .foregroundStyle(.white.opacity(0.75))
                            }

                            Text(session.place?.name ?? "Active session")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text("Started at \(session.startedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.65))
                        }

                        Spacer(minLength: 4)

                        VStack(alignment: .trailing, spacing: 5) {
                            Text("ELAPSED")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.white.opacity(0.65))

                            Text(elapsedTime(at: context.date))
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                        }
                    }
                    HStack {
                        let progress = expectedDuration.map {
                            progressCalculator.progress(
                                startedAt: session.startedAt,
                                expectedDuration: $0,
                                now: context.date
                            )
                        }
                        if let expectedDuration, let progress {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("SESSION PROGRESS")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.white.opacity(0.65))

                                    Spacer()

                                    Text("\(Int(progress * 100))%")
                                        .font(.caption.weight(.semibold))
                                        .monospacedDigit()
                                        .foregroundStyle(.white)
                                }

                                ProgressView(value: progress)
                                    .tint(.green)

                                HStack {
                                    Text("Expected duration")
                                        .foregroundStyle(.white.opacity(0.65))

                                    Spacer()

                                    Text(formattedDuration(expectedDuration))
                                        .foregroundStyle(.white)
                                }
                                .font(.caption)
                            }
                        } else {
                            Text("Complete at least 3 sessions to establish an expected duration.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.65))
                        }

                    }
                }

                .padding(16)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.08, green: 0.30, blue: 0.27),
                                    Color(red: 0.08, green: 0.20, blue: 0.30)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                }
            }
        }
    }

    private func elapsedTime(at date: Date) -> String {
        let elapsed = max(0, date.timeIntervalSince(session.startedAt))

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: elapsed) ?? "00:00"
    }
    private func formattedDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated

        return formatter.string(from: duration) ?? "—"
    }
}
