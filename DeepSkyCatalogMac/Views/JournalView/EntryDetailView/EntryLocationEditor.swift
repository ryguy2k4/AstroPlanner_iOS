//
//  EntryLocationEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/21/23.
//

import SwiftUI
import SwiftData

struct EntryLocationEditor: View {
    @Environment(\.dismiss) var dismiss
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: [SavedLocation]
    @Binding var location: Location?
    @State var locationProxy: Location
    
    init(location: Binding<Location?>) {
        self._location = location
        self._locationProxy = State(initialValue: location.wrappedValue ?? Location.default)
    }
    
    var body: some View {
        VStack {
            TextField("Latitude", value: $locationProxy.latitude, format: .number)
            TextField("Longitude", value: $locationProxy.longitude, format: .number)
            Picker("Location", selection: $locationProxy) {
                ForEach(locationList) { saved in
                    Text(saved.name).tag(Location(saved: saved))
                }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    self.location = self.locationProxy
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button("Remove") {
                    self.location = nil
                    dismiss()
                }
            }
        }
    }
}
