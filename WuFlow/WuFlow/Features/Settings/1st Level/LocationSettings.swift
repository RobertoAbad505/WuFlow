//
//  LocationSettings.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/14/26.
//
import CoreLocation
import SwiftUI
import SwiftData

struct LocationSettings: View {
    
    @State var location: CLLocation?
    @Environment(LocationService.self)
    private var locationService
    @Environment(\.repository) var repository
    @Query(sort: \Place.name) private var places: [Place]
    @State var placeId: Place.ID?
    
    var body: some View {
        VStack {
            ScrollView {
                title
                content
                debugConsole
            }
        }
    }
    var content: some View {
        VStack(spacing: 25) {
            permissionSection
            gpsDataSection
            monitorRegions
            placesList
        }
        .padding()
    }
    var title: some View {
        VStack {
            Text("Location Settings")
                .font(Font.largeTitle.weight(.bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
        }
        .padding()        
    }
    var placesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Places")
                .font(.headline)
            ForEach(places) { place in
                PlaceRow(
                    place: place,
                    isSelected: place.id == placeId) {
                    self.placeId = place.id
                }
                .onTapGesture {
                    print("Place: \(place.name)")
                    print("lat: \(place.latitude)")
                    print("long: \(place.longitude)")
                    print("identifier: \(place.identifier)")
                    print("------------------")
                }
                .onAppear {
                    print("Place: \(place.name)")
                    print("lat: \(place.latitude)")
                    print("long: \(place.longitude)")
                    print("identifier: \(place.identifier)")
                    print("------------------")
                }
            }
        }
    }
    var permissionSection: some View {
        VStack {
            Text("GPS Permission")
                .font(Font.body.weight(.semibold))
                .foregroundColor(.secondary)
            Text("Current authorization:\n\(locationService.authorizationDescription)")
                .font(.body)
            HStack {
                Button(action: {
                    locationService.requestPermission()
                }, label: {
                    Text("Request authorization")
                })
                Button(action: {
                    locationService.requestAlwaysPermission()
                }, label: {
                    Text("Request always authorization")
                })
                
            }
            .buttonStyle(.glass)
        }
    }
    var gpsDataSection: some View {
        VStack {
            Text("Current Location")
                .font(Font.body.weight(.semibold))
            Text(getCoordenatesStringFormatt(locationService.currentLocation))
                .font(Font.body.weight(.semibold))
            Button(action: {
                print("Refresh location tapped ...")
                locationService.requestCurrentLocation()
            }, label: {
                Text("Refresh location")
            })
            .buttonStyle(.glass)
        }
    }
    var monitorRegions: some View {
        VStack(spacing: 25) {
            Text("Monitor regions")
                .font(Font.body.weight(.semibold))
            Text("Last event: \(locationService.lastRegionEvent)")
                .font(.footnote.bold())
            HStack {
                Button(action: {
                    startMonitoring()
                }, label: {
                    Text("Start monitoring")
                })
                .buttonStyle(.glass)
                Button(action: {
                    print("STOP monitoring ...")
                    locationService.stopMonitoring()
                    locationService.printMonitoredRegions()
                }, label: {
                    Text("Stop monitoring")
                })
                .buttonStyle(.glass)
                
            }
            HStack {
                Button("Determine all states") {
                    for place in places {
                        locationService.requestState(place: place)
                    }
                }
                .buttonStyle(.glass)
                Button("Determine state") {
                    places.first(where: { $0.id == placeId })
                }
                .buttonStyle(.glass)
            }
            HStack {
                Button("Simulate Enter Gym") {
                    simulateEnter(regionIdentifier: "🏋️ GYM")
                }
                .buttonStyle(.glass)
                Button("Simulate exit Gym") {
                    simulateExit(regionIdentifier: "🏋️ GYM")
                }
                .buttonStyle(.glass)
            }
            HStack {
                Button("Clear Logs") {
                    locationService.clearLogs()
                }
                .buttonStyle(.glass)
            }
        }
    }
    var debugConsole: some View {
        LazyVStack(alignment: .leading, spacing: 2) {
            ForEach(locationService.debugEvents.reversed()) { event in
                DebugLogRow(event: event)
            }
        }
        .padding(5)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    func getCoordenatesStringFormatt(_ location: CLLocation?) -> String {
        guard let location else { return "-" }
        return "\(location.coordinate.latitude), \(location.coordinate.longitude)"
    }
    func startMonitoring() {
        guard let repository else {
            return
        }
        print("START monitoring ...")
        Task {
            do {
                var places = try await repository.monitoredPlaces()
                for place in places {
                    locationService.startMonitoring(place: place)
                }
            } catch let error {
                print("Error starting monitoring places")
                print(error.localizedDescription)
            }
        }
    }
    func simulateEnter(regionIdentifier: String) {
        Task {
            await locationService.automationEngine.handle(
                regionIdentifier: "🏋️ GYM",
                event: .entered
            )
        }
    }

    func simulateExit(regionIdentifier: String) {
        Task {
            await locationService.automationEngine.handle(
                regionIdentifier: "🏋️ GYM",
                event: .exited
            )
        }
    }
}
struct DebugLogRow: View {

    let event: DebugEvent

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: event.level.icon)
                .foregroundStyle(event.level.color)
                .font(.system(size: 9))
            Text(
                event.date.formatted(
                    date: .omitted,
                    time: .standard
                )
            )
            .foregroundStyle(.secondary)
            .frame(width: 70, alignment: .leading)
            .font(.system(size: 10, design: .monospaced))

            Text(event.message)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .font(.system(size: 11, design: .monospaced))
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    LocationSettings()
}
