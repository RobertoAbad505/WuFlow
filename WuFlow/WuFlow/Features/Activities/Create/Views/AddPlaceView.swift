//
//  AddPlaceView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/16/26.
//


import SwiftUI
import CoreLocation

struct AddPlaceView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.repository) private var repository
    @Environment(LocationService.self) private var locationService

    @State private var name = ""
    @State private var radius: CLLocationDistance = 100

    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var isSaving = false
    

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    header
                    nameSection
                    locationSection
                    radiusSection
                    saveButton
                }
                .padding()
            }
            .navigationTitle("New Place")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
private extension AddPlaceView {

    var header: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text("Create a Place")
                .font(.largeTitle.bold())

            Text("""
This place can be assigned to activities and used for \
location automations.
""")
            .foregroundStyle(.secondary)
        }
    }
    
    var nameSection: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Name")
                .font(.headline)

            TextField("Gym", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }
    var locationSection: some View {

        VStack(alignment: .leading, spacing: 16) {

            Text("Current Location")
                .font(.headline)

            Group {

                if let latitude,
                   let longitude {

                    VStack(alignment: .leading, spacing: 8) {

                        Label(
                            "Location Captured",
                            systemImage: "checkmark.circle.fill"
                        )
                        .foregroundStyle(.green)

                        Text(String(format: "%.5f, %.5f",
                                    latitude,
                                    longitude))
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)

                    }

                } else {

                    Label(
                        "Location not captured",
                        systemImage: "location.slash"
                    )
                    .foregroundStyle(.secondary)

                }

            }

            Button {

                captureCurrentLocation()

            } label: {
                Label("Use Current Location", systemImage: "location.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .glassEffect()

    }
    var radiusSection: some View {

        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Radius")
                Spacer()
                Text("\(Int(radius)) m")
                    .foregroundStyle(.secondary)
            }
            Slider(
                value: $radius,
                in: 25...500,
                step: 25
            )
        }
        .padding()
        .glassEffect()
    }
    var saveButton: some View {
        Button {
            save()
        } label: {

            if isSaving {
                ProgressView()
            } else {
                Text("Save Place")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(
            name.isEmpty ||
            latitude == nil ||
            longitude == nil
        )
    }
}
private extension AddPlaceView {

    func captureCurrentLocation() {
        locationService.requestCurrentLocation()

        guard let location = locationService.currentLocation else {
            return
        }

        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }

    func save() {

        guard let repository, let latitude, let longitude else {
            return
        }
        isSaving = true
        Task {

            do {
                try await repository.createPlace(
                    identifier: name,
                    name: name,
                    latitude: latitude,
                    longitude: longitude,
                    radius: radius)

                await MainActor.run {
                    dismiss()
                }
            } catch {
                print(error)
            }

            await MainActor.run {
                isSaving = false
            }
        }
    }

}
