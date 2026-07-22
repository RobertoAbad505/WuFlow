//
//  LocationService.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/14/26.
//

import Observation
import Foundation
import CoreLocation
import UIKit
import SwiftUI

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    
    var debugEvents: [DebugEvent] = []
    var currentLocation: CLLocation?
    private let manager = CLLocationManager()
    
    var lastRegionEvent: String = "None"
    
    var monitoredRegionCount: Int {
        manager.monitoredRegions.count
    }
    var monitoredRegionIdentifiers: [String] {
        manager.monitoredRegions.map(\.identifier)
    }
    
    let automationEngine: LocationAutomationEngine

    init(automationEngine: LocationAutomationEngine) {
        self.automationEngine = automationEngine
        super.init()
        manager.delegate = self
        log("🌎 LocationService initialized")
    }
        
    func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            log("GPS requesting permission ...")
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            log("GPS authorization: RESTRICTED OR DENIED")
            //navigate to settings
            UIApplication.shared.open(
                URL(string: UIApplication.openSettingsURLString)!
            )
        case .authorizedWhenInUse:
            log("GPS authorization: authorized when in use")
        case .authorizedAlways:
            log("GPS authorization: authorized always")
        @unknown default:
            log("GPS authorization: Error")
        }
    }
    func requestCurrentLocation() {
        switch manager.authorizationStatus {
        case .authorizedAlways,
             .authorizedWhenInUse:
            log("GPS Requesting current location")
            manager.requestLocation()
        case .notDetermined:
            log("GPS Request permission first.")
        case .restricted,
             .denied:
            log("GPS Location permission denied.")
        @unknown default:
            log("GPS Error requestCurrentLocation()")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        self.currentLocation = locations.last
        log("----------------------------")
        log("Accuracy: \(location.horizontalAccuracy)")
        log("Latitude: \(location.coordinate.latitude)")
        log("Longitude: \(location.coordinate.longitude)")
        log("Current location")
        log("----------------------------")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            log("GPS Authorization: Not Determined")
        case .restricted, .denied:
            log("GPS Authorization: restricted - denied")
        case .authorizedAlways:
            log("GPS Authorization: authorized always")
        case .authorizedWhenInUse:
            log("GPS Authorization: authorized when in use")
        @unknown default:
            log("GPS Authorization: Error")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log("Location Error: \(error.localizedDescription)")
    }
    
    //monitor region
    func startMonitoring(place: Place) {
        
        guard !manager.monitoredRegions.contains(where: {
            $0.identifier == place.region.identifier
        }) else {
            print("Already monitoring \(place.identifier)")
            return
        }
        
        let center = CLLocationCoordinate2D(
            latitude: place.latitude,
            longitude: place.longitude
        )

        let monitoredRegion = CLCircularRegion(
            center: center,
            radius: place.radius,
            identifier: place.identifier
        )
        manager.startMonitoring(for: monitoredRegion)
        manager.requestState(for: monitoredRegion)
    }
    func requestState(place: Place) {
        guard let monitoredRegion = manager.monitoredRegions.first(where: {
            $0.identifier == place.identifier
        }) else {
            return
        }        
        manager.requestState(for: monitoredRegion)
    }
    func stopMonitoring() {

        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }

        log("Stopped monitoring all regions.")
    }
    //didEnterRegion
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        log("Entered: \(region.identifier)")
        lastRegionEvent = "Entered \(region.identifier)"
        Task {
            await automationEngine.handle(
                regionIdentifier: region.identifier,
                event: .entered
            )
        }
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        log("Exited: \(region.identifier)")
        lastRegionEvent = "Exited \(region.identifier)"
        Task {
            await automationEngine.handle(
                regionIdentifier: region.identifier,
                event: .exited
            )
        }
    }
    func printMonitoredRegions() {
        log("──---── Monitored Regions ────")

        for region in manager.monitoredRegions {
            log(region.identifier)
        }

        log("Total: \(manager.monitoredRegions.count)")
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            log("STATE: Already inside \(region.identifier)")

        case .outside:
            log("STATE: Outside \(region.identifier)")

        case .unknown:
            log("STATE: unkown for \(region.identifier); state: location unknown state ...")
        @unknown default:
            break
        }
    }
    func requestAlwaysPermission() {
        manager.requestAlwaysAuthorization()
    }
}
extension LocationService {
    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }
    var authorizationDescription: String {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            return "Authorized Always"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        @unknown default:
            return "Error unknown case in switch statement in LocationService class authorizationDescription"
        }
    }
    var latitude: Double? {
        currentLocation?.coordinate.latitude
    }

    var longitude: Double? {
        currentLocation?.coordinate.longitude
    }
    private func log(_ message: String, _ level: DebugLevel = .info) {
        let event = DebugEvent(
            message: message,
            level: .info
        )
        debugEvents.append(event)
        if debugEvents.count > 50 {
            debugEvents.removeFirst()
        }
        print(message)
    }
    func clearLogs() {
        debugEvents.removeAll()
    }
}
