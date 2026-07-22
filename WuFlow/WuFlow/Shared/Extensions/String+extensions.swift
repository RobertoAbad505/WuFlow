//
//  String+extensions.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/22/26.
//

import Foundation
extension String {

    var removingEmojis: String {
        self
            .filter { !$0.isEmoji }
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
