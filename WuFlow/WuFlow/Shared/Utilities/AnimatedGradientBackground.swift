//
//  AnimatedGradientBackground.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/9/26.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    
    let style: BackgroundStyle
    
    private var config: BackgroundConfig {
        BackgroundConfig.config(for: style)
    }
    
    var body: some View {
        ZStack {            
            AnimatedGradientView(
                colorsA: config.gradientA,
                colorsB: config.gradientB
            )
            
            ForEach(config.blobs) { blob in
                FloatingBlobView(config: blob)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: style) // 🔥 transition
    }
    
}

struct AnimatedGradientView: View {
    
    let colorsA: [Color]
    let colorsB: [Color]
    
    @State private var animate = false
    
    var body: some View {
        LinearGradient(
            colors: animate ? colorsA : colorsB,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            animate.toggle()
        }
        .animation(
            .easeInOut(duration: 10)
            .repeatForever(autoreverses: true),
            value: animate
        )
    }
}

struct FloatingBlobView: View {
    
    let config: BlobConfig
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(config.color)
            .frame(width: config.size, height: config.size)
            .blur(radius: config.size * 0.4)
            .offset(animate ? config.finalOffset : config.initialOffset)
            .onAppear {
                animate.toggle()
            }
            .animation(
                .easeInOut(duration: config.animationDuration)
                .repeatForever(autoreverses: true),
                value: animate
            )
    }
}


#Preview {
    VStack {
        AnimatedBackgroundView(style: .calm)
    }
}
