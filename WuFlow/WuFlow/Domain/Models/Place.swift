//
//  Place.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/15/26.
//
import Foundation
import SwiftData
import CoreLocation

@Model
final class Place {

    @Attribute(.unique)
    var identifier: String

    var name: String

    var latitude: Double

    var longitude: Double

    var radius: Double

    var isMonitored: Bool
    
    var createdAt: Date
    
    init(
        identifier id: String,
        name: String,
        latitude: Double,
        longitude: Double,
        isMonitored: Bool = true,
        radius: Double = 100,
        createdAt: Date = .now
    ) {
        self.identifier = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isMonitored = isMonitored
        self.radius = radius
        self.createdAt = createdAt
    }
}
extension Place {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var region: CLCircularRegion {
        let region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: identifier
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
}
