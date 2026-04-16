//
//  StreakBadge.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/15/26.
//
import SwiftUI

struct StreakBadge: View {
    let streak: Int
    var body: some View {
        HStack {
            Text("🔥 \(streak) day" + (streak > 1 ? "s":""))
                .font(.caption2)
                .foregroundStyle(.white)
                .frame(maxWidth: 100, alignment: .center)
        }
        .padding(.vertical, 5)
        .background(.gray)
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(.white, lineWidth: 1)
        }
    }
}
