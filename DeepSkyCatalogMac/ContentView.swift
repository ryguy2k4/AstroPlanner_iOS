//
//  ContentView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/4/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) private var locationList: FetchedResults<SavedLocation>
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("List") {
                    List(locationList) { location in
                        Text("\(location.name!): \(location.longitude), \(location.latitude)")
                    }
                }
                NavigationLink("Empty") {
                    EmptyView()
                }
            }
        }
    }
}
