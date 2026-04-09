//
//  BlobModel.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/9/26.
//
import Foundation
import SwiftUI

struct BlobConfig: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let initialOffset: CGSize
    let finalOffset: CGSize
    let animationDuration: Double
}
