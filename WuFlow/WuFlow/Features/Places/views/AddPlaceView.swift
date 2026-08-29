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
    @State private var isMonitored = false
    
    @State private var identifier: String?
    @State private var isEditing: Bool = false
    
    
    init(_ updatePlace: Place? = nil) {
        if let updatePlace {
            _identifier = State(initialValue: updatePlace.identifier)
            _name = State(initialValue: updatePlace.name)
            _radius = State(initialValue: updatePlace.radius)
            _latitude = State(initialValue: updatePlace.latitude)
            _longitude = State(initialValue: updatePlace.longitude)
            _isEditing = State(initialValue: true)
            _isMonitored = State(initialValue: updatePlace.isMonitored)
        }
    }

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
            .navigationTitle(isEditing ? "New Place":"Edit Place")
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
                    Label("Location not captured", systemImage: "location.slash")
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
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))

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
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
    }
    var saveButton: some View {
        Button {
            if isEditing {
                edit()
            } else {
                save()
            }
        } label: {

            if isSaving {
                ProgressView()
            } else {
                Text(isEditing ? "Update Place":"Create new Place")
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
    func edit() {

        guard let repository, let latitude, let longitude, let identifier else {
            return
        }
        isSaving = true
        Task {

            do {
                let draft = PlaceDraft(
                    identifier: identifier,
                    name: name,
                    latitude: latitude,
                    longitude: longitude,
                    radius: radius,
                    isMonitored: isMonitored
                )
                try await repository.editPlace(id: identifier,
                                               draft: draft)

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

#Preview {
    AddPlaceView(Place(identifier: "12345", name: "GYM", latitude: 1655465, longitude: 654654))
}
