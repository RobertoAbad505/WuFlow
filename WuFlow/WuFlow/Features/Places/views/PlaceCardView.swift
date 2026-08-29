//
//  PlaceCardView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 8/28/26.
//

import SwiftUI

struct PlaceCardView: View {
    
    let place: Place
    
    init(_ place: Place) {
        self.place = place
    }
    
    var body: some View {
        VStack {
            Image("activityImg")
                .resizable()
                .frame(width: 170, height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            Text("📍 \(place.name)")
        }
        .frame(width: 180)
        .padding()
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    VStack {
        ZStack {
            Image("zengarden")
                .resizable()
                .ignoresSafeArea()
                .blur(radius: 10)
            VStack(spacing: 20) {
                PlaceCardView(Place(identifier: "123", name: "Iron GYM", latitude: 12345, longitude: 12345))
                PlaceCardView(Place(identifier: "123", name: "Home", latitude: 12345, longitude: 12345))
                PlaceCardView(Place(identifier: "123", name: "School", latitude: 12345, longitude: 12345))
            }
            .padding()
            .padding(.vertical)
        }
    }
}
