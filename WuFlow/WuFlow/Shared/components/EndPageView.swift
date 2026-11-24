//
//  EndPageView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 11/24/26.
//

import SwiftUI

struct EndPageView: View {
    var body: some View {
        HStack {
            Spacer()
            WuWeiMark(size: 15)
            Spacer()
        }
        .padding(.vertical, 25)
    }
}

#Preview {
    EndPageView()
}
