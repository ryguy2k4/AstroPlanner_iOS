//
//  Mac_LocationSettings.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import SwiftUI
import CoreLocation
import Combine

struct Mac_LocationSettings: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: FetchedResults<SavedLocation>
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        NavigationStack {
            if locationList.isEmpty {
                Text("Add a location with the plus button")
                    .padding()
            }
            List(locationList) { location in
                NavigationLink(destination: LocationEditor(location: location)) {
                    Text(location.name!)
                        .foregroundColor(.primary)
                }
            }
            .toolbar() {
                // Button for adding a new location
                ToolbarItem(placement: .automatic) {
                    NavigationLink(destination: LocationEditor(location: nil)) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
    }
}

struct LocationEditor: View {
    let location: SavedLocation?
    var body: some View {
        Text("Editor")
    }
}
