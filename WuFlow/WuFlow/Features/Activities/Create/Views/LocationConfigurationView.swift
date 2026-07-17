//
//  LocationConfigurationView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/16/26.
//


import SwiftUI
import SwiftData

struct LocationConfigurationView: View {

    @Binding var draft: ActivityDraft

    @Environment(\.repository) private var repository
    @Query(sort: \Place.name) private var places: [Place]
    @State private var showingAddPlace = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Location")
                    .font(.largeTitle.bold())
                Text("Choose the place that should trigger this activity.")
                    .foregroundStyle(.secondary)
            }

            if places.isEmpty {
                ContentUnavailableView(
                    "No Places",
                    systemImage: "mappin.and.ellipse",
                    description: Text("Create your first place to enable location automation.")
                )
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Place")
                        .font(.headline)
                    ForEach(places) { place in
                        PlaceRow(
                            place: place,
                            isSelected: draft.placeID == place.id) {
                            draft.placeID = place.id
                        }
                    }
                }
            }
            Button {
                showingAddPlace = true
            } label: {
                Label("Add Place", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Spacer()

        }
        .padding()
        .sheet(isPresented: $showingAddPlace) {
            AddPlaceView()
        }
    }
}
struct PlaceRow: View {
    let place: Place
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(place.name)
                    .font(.headline)
                Text("\(Int(place.radius)) m")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            .padding()
            .padding(.leading, 15)
            .glassEffect()
        }
        .buttonStyle(.plain)
    }
}
