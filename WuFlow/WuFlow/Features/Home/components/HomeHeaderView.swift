//
//  HeaderView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/5/26.
//

import SwiftUI

struct HomeHeaderView: View {
    
    let userName: String = "Roberto"

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 5) {
                Text("\(HomeHeaderView.currentGreeting()),")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppColors.oceanBlue)
                Text(userName)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(AppColors.midnightNavy)
                Text("Let’s keep your flow today")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                Spacer(minLength: 70)
            }
        }
        .padding(.bottom, 60)
    }
}
private extension HomeHeaderView {
    static func currentGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<18:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
}

#Preview {
    HomeHeaderView()
}
