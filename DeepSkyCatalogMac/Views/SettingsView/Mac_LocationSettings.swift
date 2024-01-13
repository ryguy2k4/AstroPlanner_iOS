//
//  Mac_LocationSettings.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 7/14/23.
//

import SwiftUI
import SwiftData
import CoreLocation
import Combine

struct Mac_LocationSettings: View {
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: [SavedLocation]
    @Environment(\.modelContext) var context
    @State var creatorModal: Bool = false
    @State var editorModal: SavedLocation? = nil
    
    var body: some View {
        VStack {
            if locationList.isEmpty {
                ContentUnavailableView("No Saved Locations", systemImage: "location")
            }
            List {
                ForEach(locationList) { location in
                    Button(location.name) {
                        editorModal = location
                    }
                    .buttonStyle(.plain)
                }
                // Button for adding a new location
                Section {
                    Button {
                        creatorModal = true
                    } label: {
                        Label("New Location", systemImage: "plus.circle")
                    }
                }
            }

            .sheet(isPresented: $creatorModal) {
                LocationEditor(location: nil)
            }
            .sheet(item: $editorModal) { location in
                LocationEditor(location: location)
            }
        }
    }
}

struct LocationEditor: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State var showErrorAlert = false
    @State var showLocationPermissionError = false
    @State var showLocationError = false
    @State var showConfirmationMessage = false
    @State var confirmationClosure: (() -> (save: () -> Void, lat: Double, long: Double, time: TimeZone))?
    @EnvironmentObject var locationManager: LocationManager
    @Query var locationList: [SavedLocation]
    
    // Local state variables to hold information being entered
    @State private var name: String = "New Location"
    @State private var longitude: Double? = nil
    @State private var latitude: Double? = nil
    @State private var timezone: TimeZone? = nil
    @State private var elevation: Double? = nil
    @State private var bortle: Int? = nil
    let location: SavedLocation?
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        // Name
                        TextField("Name: ", text: $name)
                            .padding(.top)
                        // Latitude
                        TextField("Latitude: ", value: $latitude, format: .number)
                        // Longitude
                        TextField("Longitude: ", value: $longitude, format: .number)
                        // Timezone
                        Picker("Timezone: ", selection: $timezone) {
                            let empty: TimeZone? = nil
                            ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { zone in
                                Text(zone.description).tag(TimeZone(identifier: zone))
                            }
                            Text("Choose").tag(empty)
                                .font(.italic(.body)())
                        }
                        TextField("Elevation: ", value: $elevation, format: .number)
                        TextField("Bortle: ", value: $bortle, format: .number)
                        
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
                    }
                }
                if let latitude = latitude {
                    Text(latitude.formatDMS(directionArgs: [.minus : "S", .plus : "N"]))
                }
                if let longitude = longitude {
                    Text(longitude.formatDMS(directionArgs: [.minus : "W", .plus : "E"]))
                }
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(location != nil ? "Save \(name)" : "Add \(name)") {
                        if let latitude = latitude, let longitude = longitude, let timezone = timezone {
                            if let location = location {
                                confirmationClosure = {
                                    let save = {
                                        location.latitude = latitude; location.longitude = longitude; location.timezone = timezone.identifier; location.elevation = elevation; location.bortle = bortle
                                    }
                                    return (save: save, lat: latitude, long: longitude, time: timezone)
                                }
                                showConfirmationMessage = true
                            } else if !locationList.contains(where: {$0.name == name}) {
                                confirmationClosure = {
                                    let save = {
                                        let newLocation = SavedLocation(isSelected: false, latitude: latitude, longitude: longitude, name: name, timezone: timezone.identifier, elevation: elevation, bortle: bortle)
                                        context.insert(newLocation)
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
                ToolbarItem(placement: .destructiveAction) {
                    if let location = location {
                        // delete button
                        Button("Delete \(name)", role: .destructive) {
                            context.delete(location)
                            dismiss()
                        }
                    } else {
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
                    }
                }
            }
            .alert("Confirm Location", isPresented: $showConfirmationMessage, presenting: confirmationClosure, actions: { location in
                Button {
                    location().save()
                    dismiss()
                } label: {
                    Text("Confirm")
                }
                Button("Cancel") {}
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
                    self.name = location.name
                    self.latitude = location.latitude
                    self.longitude = location.longitude
                    self.timezone = TimeZone(identifier: location.timezone)
                    self.elevation = location.elevation
                    self.bortle = location.bortle
                }
            }
        }
    }
}
