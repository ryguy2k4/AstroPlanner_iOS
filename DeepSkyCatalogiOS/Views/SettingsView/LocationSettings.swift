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
    
    var body: some View {
        NavigationStack {
            List(locationList) { location in
                NavigationLink(destination: LocationEditor(location: location)) {
                    Text(location.name!)
                        .foregroundColor(.primary)
                }
            }
            .toolbar() {
                // Button for adding a new location
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: LocationEditor(location: nil)) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .navigationTitle("Saved Locations")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct LocationEditor: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @FocusState var isInputActive: Bool
    @State var showErrorAlert = false
    @State var showLocationError = false
    let locationManager = LocationManager()
    @FetchRequest(sortDescriptors: []) var locationList: FetchedResults<SavedLocation>
    
    // Local state variables to hold information being entered
    @State private var name: String = "New Location"
    @State private var longitude: Double? = nil
    @State private var latitude: Double? = nil
    @State private var timezone: TimeZone? = nil
    let location: SavedLocation?
    
    var body: some View {
        NavigationStack {
            Form {
                ConfigSection(footer: "Enter the numbers in decimal form, not degrees, minutes, and seconds. Don't forget negative signs for western longitudes. Timezone must match coordinates.") {
                    // Name
                    LabeledTextField(text: $name, label: "Name: ", keyboardType: .default)
                        .focused($isInputActive)
                    // Latitude
                    HStack {
                        Text("Latitude: ")
                            .font(.callout)
                        TextField("Latitude: ", value: $latitude, format: .number)
                            .keyboardType(.numbersAndPunctuation)
                            .focused($isInputActive)
                    }
                    // Longitude
                    HStack {
                        Text("Longitude: ")
                            .font(.callout)
                        TextField("Longitude: ", value: $longitude, format: .number)
                            .keyboardType(.numbersAndPunctuation)
                            .focused($isInputActive)
                    }
                    
                    // Timezone
                    Picker("Timezone: ", selection: $timezone) {
                        let empty: TimeZone? = nil
                        ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { zone in
                            Text(zone.description).tag(TimeZone(identifier: zone))
                        }
                        Text("Choose").tag(empty)
                            .font(.italic(.body)())
                    }
                    .pickerStyle(.navigationLink)
                    
                    // automatically update timezone when latitude and longitude are entered
                    .onChange(of: latitude) { newValue in
                        if let lat = newValue, let long = longitude {
                            let location = CLLocation(latitude: lat, longitude: long)
                            LocationManager.getTimeZone(location: location) { timezone in
                                if let timezone = timezone {
                                    self.timezone = timezone
                                }
                            }
                        }
                    }
                    .onChange(of: longitude) { newValue in
                        if let long = newValue, let lat = latitude {
                            let location = CLLocation(latitude: lat, longitude: long)
                            LocationManager.getTimeZone(location: location) { timezone in
                                if let timezone = timezone {
                                    self.timezone = timezone
                                }
                            }
                        }
                    }
                }
                if location == nil {
                    Section {
                        // Button to autofill information for user's current location
                        Button("Get Current Location") {
                            self.locationManager.requestLocation()
                            timezone = Calendar.current.timeZone
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        
                        // Handle the results from the "Current Location" button
                        .onReceive(locationManager.publisher(for: \.latestLocation)) { location in
                            if let location = location {
                                self.longitude = location.coordinate.longitude
                                self.latitude = location.coordinate.latitude
                            }
                        }
                        // Show an error message if location request fails
                        .onReceive(locationManager.publisher(for: \.didFail)) { didFail in
                            if didFail {
                                showLocationError = true
                                locationManager.didFail = false
                            }
                        }
                    }
                }
                if let location = location {
                    Section {
                        // delete button
                        Button("Delete \(name)", role: .destructive) {
                            context.delete(location)
                            PersistenceManager.shared.saveData(context: context)
                            dismiss()
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    }
                }
            }
            .toolbar {
                KeyboardDismissButton(isInputActive: _isInputActive)
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(location != nil ? "Save \(name)" : "Add \(name)") {
                        if let location = location, let timezone = timezone {
                            PersistenceManager.shared.editLocation(location: location, name: name, latitude: latitude, longitude: longitude, timezone: timezone.identifier, context: context)
                            dismiss()
                        } else {
                            if let latitude = latitude, let longitude = longitude, let timezone = timezone, !locationList.contains(where: {$0.name! == name}) {
                                PersistenceManager.shared.addLocation(name: name, latitude: latitude, longitude: longitude, timezone: timezone.identifier, context: context)
                                dismiss()
                            } else {
                                showErrorAlert = true
                            }
                        }
                    }
                }
            }
            .padding(0)
            .alert("Invalid Location", isPresented: $showErrorAlert) {
                Text("OK")
            } message: {
                Text("Every parameter must be filled in or there is already a location with this name")
            }
            .alert("Location Error", isPresented: $showLocationError) {
                Text("OK")
            } message: {
                Text("Failed to get location")
            }
            .onAppear() {
                if let location = location {
                    self.name = location.name!
                    self.latitude = location.latitude
                    self.longitude = location.longitude
                    self.timezone = TimeZone(identifier: location.timezone ?? "America/Chicago")
                }
            }
        }
    }
}

//struct LocationSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationSettings()
//    }
//}
