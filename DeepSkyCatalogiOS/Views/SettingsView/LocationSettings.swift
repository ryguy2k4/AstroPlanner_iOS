//
//  LocationSettings.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/21/22.
//

import SwiftUI
import SwiftData
import CoreLocation
import CoreLocationUI
import Combine

struct LocationSettings: View {
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: [SavedLocation]
    @Environment(\.modelContext) var context
    
    var body: some View {
        NavigationStack {
            if locationList.isEmpty {
                Text("Add a location with the plus button")
                    .padding()
            }
            List(locationList) { location in
                NavigationLink(destination: LocationEditor(location: location)) {
                    Text(location.name)
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
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @FocusState var isInputActive: Bool
    @EnvironmentObject var locationManager: LocationManager
    @Query var locationList: [SavedLocation]
    
    // confirmation and error messages
    @State var showErrorAlert = false
    @State var showLocationPermissionError = false
    @State var showLocationError = false
    @State var showConfirmationMessage = false
    @State var showDeleteConfirmationMessage = false
    @State var confirmationClosure: (() -> ())?
    
    // Local state variables to hold information being entered
    @State private var name: String = "New Location"
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    @State private var timezone: TimeZone? = nil
    let location: SavedLocation?
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    // INPUT FIELDS
                    Section {
                        LabeledTextField(text: $name, label: "Name: ", keyboardType: .default)
                            .focused($isInputActive)
                        HStack {
                            Text("Latitude: ")
                                .font(.callout)
                            TextField("Latitude: ", value: $latitude, format: .number)
                                .keyboardType(.numbersAndPunctuation)
                                .focused($isInputActive)
                        }
                        HStack {
                            Text("Longitude: ")
                                .font(.callout)
                            TextField("Longitude: ", value: $longitude, format: .number)
                                .keyboardType(.numbersAndPunctuation)
                                .focused($isInputActive)
                        }
                        
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
                        .onChange(of: latitude) { _, newValue in
                            if let lat = newValue, let long = longitude {
                                let location = CLLocation(latitude: lat, longitude: long)
                                Task {
                                    if let timezone = await LocationManager.getTimeZone(location: location) {
                                        self.timezone = timezone
                                    }
                                }
                            }
                        }
                        .onChange(of: longitude) { _, newValue in
                            if let long = newValue, let lat = latitude {
                                let location = CLLocation(latitude: lat, longitude: long)
                                Task {
                                    if let timezone = await LocationManager.getTimeZone(location: location) {
                                        self.timezone = timezone
                                    }
                                }
                            }
                        }
                    } footer: {
                        Text("Enter the numbers in decimal form, not degrees, minutes, and seconds. Don't forget negative signs for western longitudes. Timezone must match coordinates.")
                    }
                    if location != nil {
                        Section {
                            // delete button
                            Button("Delete \(name)", role: .destructive) {
                                showDeleteConfirmationMessage = true
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        }
                    } else {
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
                            .onChange(of: locationManager.latestLocation) { _, latestLocation in
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
                }
                
                // Display latitude and longitude
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
                        // if fields are not empty
                        if let latitude = latitude, let longitude = longitude, let timezone = timezone {
                            // if we are in edit mode
                            if let location = location {
                                confirmationClosure = {
                                    location.latitude = latitude; location.longitude = longitude; location.timezone = timezone.identifier
                                }
                                showConfirmationMessage = true
                            // if we are in add mode, and the name is not a duplicate
                            } else if !locationList.contains(where: {$0.name == name}) {
                                confirmationClosure = {
                                    let newLocation = SavedLocation(isSelected: false, latitude: latitude, longitude: longitude, name: name, timezone: timezone.identifier)
                                    context.insert(newLocation)
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
            .alert("Confirm Location", isPresented: $showConfirmationMessage, presenting: confirmationClosure, actions: { confirmationClosure in
                Button("Cancel") {}
                Button {
                    confirmationClosure()
                    dismiss()
                } label: {
                    Text("Confirm")
                }
            }, message: { location in
                VStack {
                    Text("Latitude\n\(latitude!)º\n" + (latitude!.formatDMS(directionArgs: [.minus : "S", .plus : "N"])) + "\n\nLongitude\n\(longitude!)º\n" + longitude!.formatDMS(directionArgs: [.minus : "W", .plus : "E"]) + "\n\nTimezone\n\(String(describing: timezone!))")
                }
            })
            .alert("Invalid Location", isPresented: $showErrorAlert) {
                Text("OK")
            } message: {
                Text("Every parameter must be filled or there is already a location with this name.")
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
            .alert("Confirm Deletion", isPresented: $showDeleteConfirmationMessage) {
                Button("Cancel") {}
                Button("Delete") {
                    context.delete(location!)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this location? This cannot be undone.")
            }
            .onAppear() {
                if let location = location {
                    self.name = location.name
                    self.latitude = location.latitude
                    self.longitude = location.longitude
                    self.timezone = TimeZone(identifier: location.timezone)
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
