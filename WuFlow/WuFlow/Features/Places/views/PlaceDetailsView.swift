//
//  PlaceDetailsView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 8/28/26.
//

import SwiftUI

struct PlaceDetailsView: View {
    @State var presentDeleteDialog: Bool = false
    @State var presentEditProcess: Bool = false
    private let place: Place
    
    init(_ place: Place) {
        self.place = place
    }
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(style: .calm)
                .ignoresSafeArea()
            content
        }
        .sheet(isPresented: $presentEditProcess) {
            AddPlaceView(self.place)
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    presentEditProcess = true
                }, label: {
                    Image(systemName: "pencil")
                        .font(Font.system(size: 20))
                })
                .buttonStyle(.glass)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    presentDeleteDialog = true
                }, label: {
                    Image(systemName: "trash")
                        .font(Font.system(size: 20))
                })
                .buttonStyle(.glass)
            }
        })
    }
    
    var content: some View {
        VStack {
            VStack {
                heroImage
                heroDetails
            }
            .padding()
            Spacer()
            mapSection
        }
    }
    
    var heroImage: some View {
        Image("activityImg")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: 170, maxHeight: 190)
            .clipShape(RoundedRectangle(cornerRadius: 30))
    }
    var heroDetails: some View {
        VStack(spacing: 10) {
            Text("📍\(place.name)")
                .font(Font.largeTitle.bold())
            Text("GeoFence radius")
                .font(.headline.bold())
            Text("\(Int(place.radius)) mts")
            Text("Coordinates")
                .font(.headline.bold())
            VStack {
                Text("lat \(place.latitude)")
                Text("long \(place.longitude)")
            }
        }
    }
    var mapSection: some View {
        LocationMapView(place: place)
            .frame(height: 300)
            .frame(maxWidth: .infinity)
    }
}

#Preview("Place details") {
    NavigationStack {
        PlaceDetailsView(Place(identifier: "123", name: "Iron gym", latitude: 20.586552, longitude: -100.375174))
    }
}
