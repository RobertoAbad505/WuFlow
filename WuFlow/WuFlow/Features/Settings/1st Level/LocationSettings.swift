//
//  LocationSettings.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 7/14/26.
//
import CoreLocation
import SwiftUI

struct LocationSettings: View {
    
    @State var location: CLLocation?
//    @State var selectedMonitorRegion: TestRegion
    @Environment(LocationService.self)
    private var locationService
    
    //IRON GYM COORDENATES
    let gym = TestRegion(
        identifier: "🏋️ GYM",
        latitude: 20.586552,
        longitude: -100.375174,
        radius: 100
    )
    // Dalia 2
    let home = TestRegion(
        identifier: "🏠 Home",
        latitude: 20.587466399192166,
        longitude: -100.36885007990087,
        radius: 100
    )
    
    var body: some View {
        VStack {
            title
            content
        }
    }
    var content: some View {
        VStack(spacing: 25) {
            ScrollView {
                permissionSection
                gpsDataSection
                monitorRegions
                debugConsole
            }
        }
        .padding()
    }
    var title: some View {
        Text("Location Settings")
            .font(Font.largeTitle.weight(.bold))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
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
                    print("START monitoring ...")
                    locationService.startMonitoring(region: home)
                    locationService.startMonitoring(region: gym)
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
                Button("Determine state") {
                    locationService.requestState(region: home)
                    locationService.requestState(region: gym)
                }
                .buttonStyle(.glass)
                Button("Clear Logs") {
                    locationService.clearLogs()
                }
                .buttonStyle(.glass)
            }
            
            
        }
    }
    var debugConsole: some View {
        Section("Developer Log") {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(locationService.debugEvents.reversed()) { event in
                    DebugLogRow(event: event)
                }
            }
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    func getCoordenatesStringFormatt(_ location: CLLocation?) -> String {
        guard let location else { return "-" }
        return "\(location.coordinate.latitude), \(location.coordinate.longitude)"
    }
}
struct DebugLogRow: View {

    let event: DebugEvent

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: event.level.icon)
                .foregroundStyle(event.level.color)
                .frame(width: 10)
            Text(
                event.date.formatted(
                    date: .omitted,
                    time: .standard
                )
            )
            .foregroundStyle(.secondary)
            .frame(width: 70, alignment: .leading)

            Text(event.message)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .font(.system(size: 11, design: .monospaced))
        .padding(.vertical, 2)
    }
}

#Preview {
    LocationSettings()
}
