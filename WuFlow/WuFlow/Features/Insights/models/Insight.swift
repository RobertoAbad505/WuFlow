//
//  Insight.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/7/26.
//
import Foundation

struct Insight: Identifiable, Sendable {

    let id: UUID
    let title: String
    let message: String

    init(
        id: UUID = UUID(),
        title: String,
        message: String
    ) {
        self.id = id
        self.title = title
        self.message = message
    }
}
