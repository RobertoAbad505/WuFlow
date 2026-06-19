//
//  DayGroupView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/4/26.
//
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
