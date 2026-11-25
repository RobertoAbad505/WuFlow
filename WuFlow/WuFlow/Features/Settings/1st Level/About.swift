//
//  AboutAppView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 11/25/26.
//

import SwiftUI

struct AboutAppView: View {
    
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
                 ScrollView {
                     VStack {
                        content
                        // Animated Wu Wei mark
                        WuWeiMark(size: 35)
                    }
                     .padding(.top, 95)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .ignoresSafeArea()
    }
    
    var content: some View {
        VStack {
            header
            appInfo
        }
        .padding()
    }
    
    var header: some View {
        VStack(alignment: .center) {
            Text("- WuFlow -")
                .fontDesign(.serif)
                .font(.title.bold())
                .foregroundStyle(AppColors.midnightNavy)
            Text("無為")
                .fontDesign(.serif)
                .font(.system(size: 45).bold())
                .foregroundStyle(AppColors.midnightNavy)
                .padding(.bottom, 25)
        }
    }
    var appInfo: some View {
        VStack(alignment: .leading) {
            Text("about this app:")
                .font(.subheadline)
            Text("""
                 WuFlow started as a habit tracker and evolved into a broader exploration of personal behavior.
                Its guiding idea is:
                
                - Observe behavior before trying to change it -
                
                Rather than focusing only on whether a habit was completed, WuFlow brings together person's daily experience.
                The goal is to make tracking less dependent on manual input while keeping people in control of their data and how it is interpreted.
                """
            )
            .font(.subheadline)
            
            Text("Learn more visiting the study case at my Web portfolio or GitHub public repo:")
                .font(.subheadline)
            buttons
        }
        .padding()
        .background(.regularMaterial.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 40))
    }
    var buttons: some View {
        VStack(alignment: .center) {
            Link(destination: URL(string:  "https://roberto-abad.web.app/")!) {
                Label("Visit case study", systemImage: "globe")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(AppColors.midnightNavy, in: Capsule())
            }
            .buttonStyle(.plain)
            Link(destination: URL(string:  "https://github.com/RobertoAbad505/WuFlow")!) {
                Label(title: {
                    Text("Visit GitHub public repo")
                }, icon: {
                    Image("gitIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .backgroundStyle(.white)
                })
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .background(AppColors.secondaryText, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    AboutAppView()
}
