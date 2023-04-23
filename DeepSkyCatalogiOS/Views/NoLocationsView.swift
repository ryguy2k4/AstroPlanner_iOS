//
//  NoLocationsView.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/26/23.
//

import SwiftUI

struct NoLocationsView: View {
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
        }
    }
}
