//
//  LocationSettings.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/21/22.
//

import SwiftUI
import CoreLocation
import CoreLocationUI
import Combine

struct LocationSettings: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: FetchedResults<SavedLocation>
    @Environment(\.managedObjectContext) var context
    @State private var locationEditorModal: Bool = false
    
    var body: some View {
        Form {
            ConfigSection(header: "Locations", footer: "Swipe left on a location to delete") {
                // Display each location preset
                List(locationList) { location in
                    Text(location.name!)
                        .swipeActions() {
                            if locationList.count > 1 {
                                Button(role: .destructive) {
                                    context.delete(location)
                                    PersistenceManager.shared.saveData(context: context)
                                    
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .foregroundColor(.primary)
                }
                // Button for adding a new location
                Button(action: { locationEditorModal = true }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Location")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $locationEditorModal) {
            LocationEditor()
                .presentationDetents([.fraction(0.8)])
        }
    }
}


struct LocationEditor: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @FocusState var isInputActive: Bool
    let locationManager = LocationManager()
    
    // Local state variables to hold information being entered
    @State private var name: String = ""
    @State private var longitudeText: String = ""
    @State private var latitudeText: String = ""
    @State private var timezone: Int16 = -6
    
    var body: some View {
        NavigationView {
            Form {
                ConfigSection(footer: "Enter the numbers in decimal form, not degrees, minutes, and seconds") {
                    // Fields to manually enter location info
                    SettingsField(text: $name, label: "Name: ", keyboardType: .default)
                        .focused($isInputActive)
                    SettingsField(text: $latitudeText, label: "Latitude: ", prompt: "Decimal Degrees")
                        .focused($isInputActive)
                    SettingsField(text: $longitudeText, label: "Longitude: ", prompt: "Decimal Degrees")
                        .focused($isInputActive)
                    Text("Timezone (GMT offset): ")
                    Picker("Timezone", selection: $timezone) {
                        ForEach(-12..<13) {
                            Text("\($0)").tag(Int16($0))
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 80)
                    
                    // Button to autofill information for user's current location
                    LocationButton() {
                        self.locationManager.requestLocation()
                        timezone = Int16(Calendar.current.timeZone.secondsFromGMT()/60/60)
                    }
                    .cornerRadius(5)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    
                    // Handle the results from the "Current Location" button
                    .onReceive(locationManager.publisher(for: \.latestLocation)) { location in
                        if let location = location {
                            self.longitudeText = "\(location.coordinate.longitude)"
                            self.latitudeText = "\(location.coordinate.latitude)"
                        }
                    }
                }
            }
            .toolbar {
                KeyboardDismissButton(isInputActive: _isInputActive)
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button("Add") {
                        PersistenceManager.shared.addLocation(name: name, latitude: Double(latitudeText) ?? .nan, longitude: Double(longitudeText) ?? .nan, timezone: timezone, context: context)
                        dismiss()
                    }
                }
            }
            .padding(0)
        }
        .onDisappear {
            PersistenceManager.shared.saveData(context: context)
        }
    }
}

//struct LocationSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationSettings()
//    }
//}
