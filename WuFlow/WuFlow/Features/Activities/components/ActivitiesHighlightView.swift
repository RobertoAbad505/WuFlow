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
                        .font(.system(size: 14, weight: .bold))
                    Text(description)
                        .font(.system(size: 9, weight: .regular))
                }
            }
            HStack {
                Text(footnote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .font(.system(size: footNoteSize, weight: .regular))
            }
        }
        .padding()
        .background(.ultraThinMaterial) 
        .frame(maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
        
    }
}

#Preview {
    VStack {
        Spacer()
        ActivitiesHighlightView(systemNameImage: "flame",
                                count: "2",
                                description: "activities",
                                footnote: "Total",
                                tint: .green)
        .frame(width: 120, height: 120)
        Spacer()
        HStack {
            Spacer()
        }
    }
    .background(.gray)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    
}
