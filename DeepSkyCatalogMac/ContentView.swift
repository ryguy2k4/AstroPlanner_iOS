//
//  ContentView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 2/4/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    var body: some View {
        Text("Hello")
        Text("\(locationList.first!.latitude)")
    }
}
