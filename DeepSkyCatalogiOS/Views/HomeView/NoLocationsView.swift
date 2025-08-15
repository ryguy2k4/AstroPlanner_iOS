//
//  NoLocationsView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/26/23.
//

import SwiftUI
import SwiftData
import DeepSkyCore

/**
 This view is displayed when there is no valid location
 It prompts the user to create a location
 If location permissions were granted, it will load the current location in a few seconds
 */
struct NoLocationsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var store: HomeViewModel
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: [SavedLocation]
    var body: some View {
        NavigationStack {
            VStack {
                Text("Add a Location")
                    .fontWeight(.semibold)
                NavigationLink(destination: LocationSettings()) {
                    Label("Locations Settings", systemImage: "location")
                }
                .padding()
            }
            // Attempt to select a location
            .onAppear() {
                store.location = {
                    if let selected = locationList.first(where: { $0.isSelected == true }) {
                        // Try to find a selected location
                        return Location(saved: selected)
                    } else if locationManager.locationEnabled, let latest = locationManager.latestLocation {
                        // Try to get the current location
                        return Location(current: latest)
                    } else if let any = locationList.first {
                        // Try to find any location
                        any.isSelected = true
                        return Location(saved: any)
                    }
                    else {
                        // No location found
                        return Location.default
                    }
                }()
                // Re-initialize date based on the selected location
                store.date = .now.startOfLocalDay(timezone: store.location.timezone)
            }
            // This onReceive is relevant when launching the app for the first time
            // and will watch for the latestLocation after location permissions are enabled
            .onReceive(locationManager.$latestLocation) { location in
                if let location = location {
                    store.location = Location(current: location)
                }
            }
            .toolbar {
                ToolbarLogo()
            }
        }
    }
}
