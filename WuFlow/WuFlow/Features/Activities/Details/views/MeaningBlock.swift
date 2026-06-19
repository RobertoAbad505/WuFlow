//
//  MeaningBlock.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/4/26.
//
import SwiftUI

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
