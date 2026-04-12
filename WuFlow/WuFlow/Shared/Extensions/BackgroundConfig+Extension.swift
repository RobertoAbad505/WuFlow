//
//  BackgroundConfig.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/12/26.
//
import SwiftUI

extension BackgroundConfig {
    
    static func config(for style: BackgroundStyle) -> BackgroundConfig {
        switch style {
            
        case .wuFlow:
            return BackgroundConfig(
                gradientA: [
                    Color.green.opacity(0.25),
                    Color.blue.opacity(0.2),
                    Color.white
                ],
                gradientB: [
                    Color.blue.opacity(0.25),
                    Color.green.opacity(0.2),
                    Color.white
                ],
                blobs: [
                    BlobConfig(
                        color: Color.green.opacity(0.2),
                        size: 250,
                        initialOffset: CGSize(width: -120, height: 150),
                        finalOffset: CGSize(width: 120, height: -150),
                        animationDuration: 12
                    )
                ]
            )
            
        case .focus:
            return BackgroundConfig(
                gradientA: [
                    Color.blue.opacity(0.3),
                    Color.indigo.opacity(0.25),
                    Color.white
                ],
                gradientB: [
                    Color.indigo.opacity(0.3),
                    Color.blue.opacity(0.25),
                    Color.white
                ],
                blobs: [
                    BlobConfig(
                        color: Color.blue.opacity(0.2),
                        size: 280,
                        initialOffset: CGSize(width: -100, height: 200),
                        finalOffset: CGSize(width: 100, height: -200),
                        animationDuration: 14
                    )
                ]
            )
            
        case .energy:
            return BackgroundConfig(
                gradientA: [
                    Color.orange.opacity(0.3),
                    Color.pink.opacity(0.25),
                    Color.white
                ],
                gradientB: [
                    Color.pink.opacity(0.3),
                    Color.orange.opacity(0.25),
                    Color.white
                ],
                blobs: [
                    BlobConfig(
                        color: Color.orange.opacity(0.25),
                        size: 300,
                        initialOffset: CGSize(width: -150, height: 150),
                        finalOffset: CGSize(width: 150, height: -150),
                        animationDuration: 10
                    )
                ]
            )
            
        case .calm:
            return BackgroundConfig(
                gradientA: [
                    Color.gray.opacity(0.2),
                    Color.blue.opacity(0.1),
                    Color.white
                ],
                gradientB: [
                    Color.blue.opacity(0.2),
                    Color.gray.opacity(0.1),
                    Color.white
                ],
                blobs: [
                    BlobConfig(
                        color: Color.gray.opacity(0.15),
                        size: 260,
                        initialOffset: CGSize(width: -120, height: 120),
                        finalOffset: CGSize(width: 120, height: -120),
                        animationDuration: 16
                    )
                ]
            )
        }
    }
}
