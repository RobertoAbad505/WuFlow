//
//  LocationPickerView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 9/12/26.
//


import SwiftUI
import MapKit

struct LocationPickerView: View {

    @Environment(\.dismiss) private var dismiss

    let initialCoordinate: CLLocationCoordinate2D?
    let onLocationSelected: (SelectedLocation) -> Void

    @State private var cameraPosition: MapCameraPosition
    @State private var selectedCoordinate: CLLocationCoordinate2D?

    init(
        initialCoordinate: CLLocationCoordinate2D? = nil,
        onLocationSelected: @escaping (SelectedLocation) -> Void
    ) {
        self.initialCoordinate = initialCoordinate
        self.onLocationSelected = onLocationSelected

        let coordinate = initialCoordinate
            ?? CLLocationCoordinate2D(
                latitude: 20.5888,
                longitude: -100.3899
            )
        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.005,
                        longitudeDelta: 0.005
                    )
                )
            )
        )
        _selectedCoordinate = State(
            initialValue: initialCoordinate
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                map
                selectionCard
                    .padding()
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var map: some View {
        MapReader { proxy in
            Map(position: $cameraPosition) {
                if let coordinate = selectedCoordinate {
                    Marker(
                        "Selected Location",
                        coordinate: coordinate
                    )
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .onTapGesture { screenPoint in

                guard let coordinate = proxy.convert(
                    screenPoint,
                    from: .local
                ) else {
                    return
                }

                selectedCoordinate = coordinate
            }
        }
        .ignoresSafeArea()
    }

    private var selectionCard: some View {
        VStack(spacing: 12) {

            if let coordinate = selectedCoordinate {

                VStack(spacing: 4) {
                    Text("Location selected")
                        .font(.headline)

                    Text(
                        String(
                            format: "%.6f, %.6f",
                            coordinate.latitude,
                            coordinate.longitude
                        )
                    )
                    .font(.caption)
                    .monospaced()
                    .foregroundStyle(.secondary)
                }

                Button {
                    onLocationSelected(
                        SelectedLocation(
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude
                        )
                    )
                    dismiss()
                } label: {
                    Label(
                        "Use This Location",
                        systemImage: "checkmark.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

            } else {

                VStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title2)

                    Text("Tap anywhere on the map")
                        .font(.headline)

                    Text("Select the location you want to use.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
}
struct SelectedLocation: Sendable {
    let latitude: Double
    let longitude: Double
}
