//
//  PlacesListView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 8/28/26.
//

import SwiftUI
import SwiftData

struct PlacesListView: View {
    @Environment(\.repository) private var repository
    @Query()
    private var places: [Place]
    private let columns = [GridItem(.flexible())]
    
    var body: some View {
        VStack {
            ZStack {
                Image("zengarden")
                    .resizable()
                    .ignoresSafeArea()
                    .blur(radius: 10)
                content
            }
        }
        .navigationDestination(for: Place.self) { selectedItem in
            PlaceDetailsView(selectedItem)
        }
    }
    
    var content: some View {
        VStack {
            ScrollView {
                header
                gridView
            }
        }
    }
    var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("📍My Places")
                    .font(.title)
                Text("Select a place to see more details")
                    .font(.subheadline)
                    .padding(.leading, 10)
            }
            Spacer()
        }
        .padding()
    }
    
    var gridView: some View {
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(places) { place in
                    NavigationLink(value: place) {
                        PlaceCardView(place)
                    }
                }
            }
        }
    }
}


#Preview("Places List") {
    // Seed initial data into an in-memory model container so @Query works in previews
    let previewItems = [
        Place(identifier: "123", name: "Iron gym", latitude: 123456, longitude: 123456),
        Place(identifier: "456", name: "Kaomi's house", latitude: 123456, longitude: 123456),
        Place(identifier: "789", name: "Cimatario", latitude: 123456, longitude: 123456),
        Place(identifier: "101", name: "Centro historico", latitude: 123456, longitude: 123456)
    ]
    NavigationStack {
        PlacesListView()
            .modelContainer(for: Place.self, inMemory: true) { result in
                if case let .success(container) = result {
                    let context = container.mainContext
                    previewItems.forEach { context.insert($0) }
                    try? context.save()
                }
            }
    }
}
