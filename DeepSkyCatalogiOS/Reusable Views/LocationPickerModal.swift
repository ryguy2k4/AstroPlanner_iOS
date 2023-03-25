//
//  LocationPicker.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/24/23.
//

import SwiftUI

struct LocationPickerModal: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    var body: some View {
        let locationBinding = Binding(
            get: { return locationList.firstIndex(where: {$0.isSelected == true}) ?? -1 },
            set: {
                for location in locationList { location.isSelected = false }
                if $0 >= 0 {
                    locationList[$0].isSelected = true
                }
                PersistenceManager.shared.saveData(context: context)
            }
        )
        Form {
            Picker("Location", selection: locationBinding) {
                if locationManager.locationEnabled {
                    Text("Current Location").tag(-1)
                }
                ForEach(Array(locationList.enumerated()), id: \.element) { index, location in
                    Text(locationList[index].name!).tag(index)
                }
            }
            .pickerStyle(.inline)
            .headerProminence(.increased)
        }
    }
}
