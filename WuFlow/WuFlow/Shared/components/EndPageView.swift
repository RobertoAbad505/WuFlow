//
//  EndPageView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 11/24/26.
//

import SwiftUI

struct EndPageView: View {
    let markSize: Double
    
    init(_ markSize: Double? = 15.0) {
        self.markSize = markSize ?? 15.0
    }
    
    var body: some View {
        HStack {
            Spacer()
            WuWeiMark(size: markSize)
            Spacer()
        }
        .padding(.vertical, 25)
    }
}

#Preview {
    EndPageView()
}
