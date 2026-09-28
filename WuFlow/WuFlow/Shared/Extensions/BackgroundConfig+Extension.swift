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
                    Color.gray.opacity(0.4),
                    Color.blue.opacity(0.5),
                    Color.white
                ],
                gradientB: [
                    Color.blue.opacity(0.5),
                    Color.gray.opacity(0.4),
                    Color.white
                ],
                blobs: [
                    BlobConfig(
                        color: Color.gray.opacity(0.25),
                        size: 160,
                        initialOffset: CGSize(width: -120, height: 120),
                        finalOffset: CGSize(width: 120, height: -120),
                        animationDuration: 10
                    )
                ]
            )
        case .growth:
            return BackgroundConfig(
                gradientA: [
                    Color.green.opacity(0.28),
                    Color.mint.opacity(0.22),
                    Color.white
                ],
                gradientB: [
                    Color.mint.opacity(0.28),
                    Color.green.opacity(0.18),
                    Color.white
                ],
                blobs: [
                    BlobConfig(
                        color: Color.green.opacity(0.18),
                        size: 220,
                        initialOffset: CGSize(width: -140, height: 180),
                        finalOffset: CGSize(width: 140, height: -120),
                        animationDuration: 16
                    )
                ]
            )
        case .reduce:
            return BackgroundConfig(
                gradientA: [
                    Color.orange.opacity(0.18),
                    Color.red.opacity(0.12),
                    Color.white
                ],
                gradientB: [
                    Color.red.opacity(0.16),
                    Color.orange.opacity(0.10),
                    Color.white
                ],
                blobs: [
                    BlobConfig(
                        color: Color.orange.opacity(0.12),
                        size: 180,
                        initialOffset: CGSize(width: -100, height: 100),
                        finalOffset: CGSize(width: 100, height: -100),
                        animationDuration: 20
                    )
                ]
            )
        case .night:
            return BackgroundConfig(
                gradientA: [
                    Color.indigo.opacity(0.75),
                    Color.purple.opacity(0.60),
                    Color.black
                ],
                gradientB: [
                    Color.purple.opacity(0.65),
                    Color.blue.opacity(0.60),
                    Color.black
                ],
                blobs: [
                    BlobConfig(
                        color: Color.indigo.opacity(0.92),
                        size: 260,
                        initialOffset: CGSize(width: -120, height: 150),
                        finalOffset: CGSize(width: 120, height: -150),
                        animationDuration: 18
                    )
                ]
            )
        case .minimal:
            return BackgroundConfig(
                gradientA: [
                    Color.white,
                    Color.gray.opacity(0.04),
                    Color.white
                ],
                gradientB: [
                    Color.gray.opacity(0.04),
                    Color.white,
                    Color.gray.opacity(0.03)
                ],
                blobs: []
            )
        }
    }
}
