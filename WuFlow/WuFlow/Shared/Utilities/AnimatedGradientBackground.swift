//
//  AnimatedGradientBackground.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/9/26.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    
    let gradientA: [Color] = [
        Color.blue.opacity(0.35),
        Color.green.opacity(0.31),
        Color.white
    ]
    let gradientB: [Color] = [
        Color.green.opacity(0.35),
        Color.blue.opacity(0.31),
        Color.white
    ]
    let blobs: [BlobConfig] = [
        BlobConfig(
            color: Color.white.opacity(1),
            size: 250,
            initialOffset: CGSize(width: -120, height: 150),
            finalOffset: CGSize(width: 120, height: -150),
            animationDuration: 12
        ),
        BlobConfig(
            color: Color.purple.opacity(0.5),
            size: 300,
            initialOffset: CGSize(width: 150, height: -200),
            finalOffset: CGSize(width: -100, height: 200),
            animationDuration: 14
        )
    ]
    
    var body: some View {
        ZStack {
            
            // Gradient layer
            AnimatedGradientView(
                colorsA: gradientA,
                colorsB: gradientB
            )
            
            // Blob layers
            ForEach(blobs) { blob in
                FloatingBlobView(config: blob)
            }
        }
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
        
    }
}
