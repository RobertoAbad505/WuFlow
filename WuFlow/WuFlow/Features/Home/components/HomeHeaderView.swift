//
//  HeaderView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 4/5/26.
//

import SwiftUI

struct HomeHeaderView: View {
    
    let userName: String = "Roberto"
    let greeting: String = "Good morning"
    let imageName: String? = nil // optional for flexibility
    
    var body: some View {
        HStack(alignment: .center) {
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(HomeHeaderView.currentGreeting()),")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(userName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Let’s keep your flow today")
                        .font(.caption)
                        .foregroundColor(.secondary)
            }
            
            Spacer()
            avatarView
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}
private extension HomeHeaderView {
    
    @ViewBuilder
    var avatarView: some View {
        if let imageName = imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundStyle(.gray)
        }
    }
    static func currentGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good morning🌅"
        case 12..<18:
            return "Good afternoon☀️"
        default:
            return "Good evening🌃"
        }
    }
}

#Preview {
    HomeHeaderView()
}
