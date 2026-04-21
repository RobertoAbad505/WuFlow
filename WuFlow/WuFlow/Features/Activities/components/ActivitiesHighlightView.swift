//
//  ActivitiesHighlightView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/15/26.
//
import SwiftUI

struct ActivitiesHighlightView: View {
    let systemNameImage: String
    let count: String
    let description: String
    let footnote: String
    let tint: Color?
    
    var footNoteSize: CGFloat {
        footnote.count > 20 ? 5 : 6
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Image(systemName: systemNameImage)
                    .symbolEffect(.breathe.byLayer)
                    .font(.system(size: 15))
                    .foregroundStyle(tint ?? .black)
                    .symbolEffect(.pulse.byLayer)
                VStack(alignment: .leading) {
                    Text(count)
                        .font(.system(size: 15, weight: .bold))
                    Text(description)
                        .font(.system(size: 9, weight: .regular))
                }
            }
            .padding(.bottom, 5)
            HStack {
                Text(footnote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .font(.system(size: footNoteSize, weight: .regular))
            }
        }
        .padding(10)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ActivitiesHighlightView(systemNameImage: "flame",
                            count: "2",
                            description: "Streak days",
                            footnote: "Strike",
                            tint: .green)
}
