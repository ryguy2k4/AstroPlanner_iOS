//
//  CatalogSettingsModal.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 3/16/23.
//

import SwiftUI

/**
 This view is for the modal that pops up on the Master Catalog to choose the date and location
 */
struct CatalogSettingsModal: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.managedObjectContext) var context
    @Environment(\.sunData) var sunData
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.isSelected, order: .reverse)]) var locationList: FetchedResults<SavedLocation>
    @Binding var date: Date
    @Binding var viewingInterval: DateInterval
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
        VStack {
            DateSelector(date: $date)
                .padding()
                .font(.title2)
                .fontWeight(.semibold)
            Form {
                ConfigSection(header: "Viewing Interval") {
                    DateIntervalSelector(viewingInterval: $viewingInterval, customViewingInterval: viewingInterval != sunData?.ATInterval, sunData: sunData)
                }
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
}
