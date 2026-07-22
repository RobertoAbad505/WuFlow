//
//  Character+extensions.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/22/26.
//

import Foundation

extension Character {
    var isEmoji: Bool {
        unicodeScalars.first?.properties.isEmoji == true
    }
}
