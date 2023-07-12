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
    @State var showLocationPermissionError = false
    @State var showLocationError = false
    @State var showConfirmationMessage = false
    @State var confirmationClosure: (() -> (save: () -> Void, lat: Double, long: Double, time: TimeZone))?
    @EnvironmentObject var locationManager: LocationManager
    @FetchRequest(sortDescriptors: []) var locationList: FetchedResults<SavedLocation>
    
    // Local state variables to hold information being entered
    @State private var name: String = "New Location"
    @State private var longitude: Double? = nil
    @State private var latitude: Double? = nil
    @State private var timezone: TimeZone? = nil
    let location: SavedLocation?
    
    var body: some View {
        NavigationStack {
            VStack {
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
                                if locationManager.locationEnabled {
                                    if let latestLocation = locationManager.latestLocation {
                                        latitude = latestLocation.coordinate.latitude
                                        longitude = latestLocation.coordinate.longitude
                                    } else {
                                        showLocationError = true
                                    }
                                } else {
                                    showLocationPermissionError = true
                                }
                                timezone = Calendar.current.timeZone
                            }
                            .onChange(of: locationManager.latestLocation) { latestLocation in
                                if let latestLocation = latestLocation {
                                    latitude = latestLocation.coordinate.latitude
                                    longitude = latestLocation.coordinate.longitude
                                } else {
                                    showLocationError = true
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
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
                if let latitude = latitude {
                    Text(latitude.formatDMS(directionArgs: [.minus : "S", .plus : "N"]))
                }
                if let longitude = longitude {
                    Text(longitude.formatDMS(directionArgs: [.minus : "W", .plus : "E"]))
                }
            }
            .toolbar {
                KeyboardDismissButton(isInputActive: _isInputActive)
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(location != nil ? "Save \(name)" : "Add \(name)") {
                        if let latitude = latitude, let longitude = longitude, let timezone = timezone {
                            if let location = location {
                                confirmationClosure = {
                                    let save = {
                                        PersistenceManager.shared.editLocation(location: location, name: name, latitude: latitude, longitude: longitude, timezone: timezone.identifier, context: context)
                                    }
                                    return (save: save, lat: latitude, long: longitude, time: timezone)
                                }
                                showConfirmationMessage = true
                            } else if !locationList.contains(where: {$0.name! == name}) {
                                confirmationClosure = {
                                    let save = {
                                        PersistenceManager.shared.addLocation(name: name, latitude: latitude, longitude: longitude, timezone: timezone.identifier, context: context)
                                    }
                                    return (save: save, lat: latitude, long: longitude, time: timezone)
                                    
                                }
                                showConfirmationMessage = true
                            } else {
                                showErrorAlert = true
                            }
                        } else {
                            showErrorAlert = true
                        }
                    }
                }
            }
            .padding(0)
            .alert("Confirm Location", isPresented: $showConfirmationMessage, presenting: confirmationClosure, actions: { location in
                Button("Cancel") {}
                Button {
                    location().save()
                    dismiss()
                } label: {
                    Text("Confirm")
                }
            }, message: { location in
                VStack {
                    Text("Latitude: \(location().lat)º / " + location().lat.formatDMS(directionArgs: [.minus : "S", .plus : "N"]) + "\nLongitude: \(location().long)º / " + location().long.formatDMS(directionArgs: [.minus : "W", .plus : "E"]) + "\nTimezone: \(String(describing: location().time))")
                }
            })
            .alert("Invalid Location", isPresented: $showErrorAlert) {
                Text("OK")
            } message: {
                Text("Every parameter must be filled, there is already a location with this name, or the latitude is too extreme")
            }
            .alert("Location Error", isPresented: $showLocationError) {
                Text("OK")
            } message: {
                Text("Failed to get location")
            }
            .alert("Location Error", isPresented: $showLocationPermissionError) {
                Text("OK")
            } message: {
                Text("Astro Planner does not have location permissions enabled")
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
