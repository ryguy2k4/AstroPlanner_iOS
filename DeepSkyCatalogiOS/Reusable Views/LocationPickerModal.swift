//
//  LocationPicker.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/24/23.
//

import SwiftUI
import SwiftData

struct LocationPickerModal: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.modelContext) var context
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: [SavedLocation]
    var body: some View {
        let locationBinding = Binding(
            get: { return locationList.firstIndex(where: {$0.isSelected == true}) ?? -1 },
            set: {
                for location in locationList { location.isSelected = false }
                if $0 >= 0 {
                    locationList[$0].isSelected = true
                }
            }
        )
        Form {
            Picker("Location", selection: locationBinding) {
                if locationManager.locationEnabled {
                    Text("Current Location").tag(-1)
                }
                ForEach(Array(locationList.enumerated()), id: \.element) { index, location in
                    Text(locationList[index].name).tag(index)
                }
            }
            .pickerStyle(.inline)
            .headerProminence(.increased)
        }
    }
}
