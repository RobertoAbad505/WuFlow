//
//  LocationMapView.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/18/26.
//
import SwiftUI
import MapKit

struct LocationMapView: View {

    let place: Place

    var body: some View {
        Map {
            Marker(
                place.name,
                coordinate: place.coordinate
            )
            MapCircle(
                center: place.coordinate,
                radius: place.radius
            )
        }
    }
}
