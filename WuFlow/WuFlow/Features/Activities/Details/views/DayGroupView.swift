//
//  DayGroupView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/4/26.
//
import Foundation
import SwiftUI

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
                    ProgressRecordRow(
                        record: record,
                        unit: unit
                    )
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
struct ProgressRecordRow: View {

    let record: ProgressRecord
    let unit: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            Image(systemName: "plus.circle.fill")
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {

                HStack {
                    Text("+\(Int(record.value)) \(unit)")
                        .font(.body)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(record.date, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let session = record.placeSession {
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                        Text(session.place?.name ?? "")
                        if let duration = session.duration {
                            Text("·")
                            Text(session.formattedDuration)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    sourceView
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var sourceView: some View {
        HStack(spacing: 5) {
            Image(systemName: record.activity.trackingType.icon)
            Text(record.activity.trackingType.title)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
