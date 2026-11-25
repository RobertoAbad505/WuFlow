//
//  SplashView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 11/24/26.
//


import SwiftUI


import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen background
                Image("SplashScreen")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
                VStack(alignment: .center, spacing: 0) {
                    Text("- WuFlow -")
                        .fontDesign(.serif)
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppColors.midnightNavy)
                    Text("無為")
                        .fontDesign(.serif)
                        .font(.system(size: 52).bold())
                        .foregroundStyle(AppColors.midnightNavy)
                        .padding(.bottom, 25)
                    // Animated Wu Wei mark
                    WuWeiMark(size: 35)
                        .rotationEffect(
                            .degrees(isAnimating ? 360 : 0)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .linear(duration: 4)
                    .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}



#Preview {
    SplashView()
}
