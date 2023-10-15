//
//  NoLocationsView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/26/23.
//

import SwiftUI

struct NoLocationsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var store: HomeViewModel
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
