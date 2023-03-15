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
    @State private var locationCreatorModal: Bool = false
    @State private var locationEditorModal: SavedLocation? = nil
    
    var body: some View {
        Form {
            ConfigSection(footer: "Swipe left on a location to delete") {
                // Display each location preset
                List(locationList) { location in
                    Text(location.name!)
                        .swipeActions() {
                            Button(role: .destructive) {
                                context.delete(location)
                                PersistenceManager.shared.saveData(context: context)
                                
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                locationEditorModal = location
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.yellow)
                        }
                        .foregroundColor(.primary)
                }
                // Button for adding a new location
                Button(action: { locationCreatorModal = true }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Location")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $locationCreatorModal) {
            LocationEditor(location: nil)
                .presentationDetents([.fraction(0.8)])
        }
        .sheet(item: $locationEditorModal) { location in
            LocationEditor(location: location)
                .presentationDetents([.fraction(0.8)])
        }
        .navigationTitle("Locations")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct LocationEditor: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @FocusState var isInputActive: Bool
    @State var showErrorAlert = false
    let locationManager = LocationManager()
    
    // Local state variables to hold information being entered
    @State private var name: String = ""
    @State private var longitude: Double? = nil
    @State private var latitude: Double? = nil
    @State private var timezone: TimeZone? = nil
    let location: SavedLocation?
    
    var body: some View {
        NavigationView {
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
                    
                    // Button to autofill information for user's current location
                    LocationButton() {
                        self.locationManager.requestLocation()
                        timezone = Calendar.current.timeZone
                    }
                    .cornerRadius(5)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    
                    // Handle the results from the "Current Location" button
                    .onReceive(locationManager.publisher(for: \.latestLocation)) { location in
                        if let location = location {
                            self.longitude = location.coordinate.longitude
                            self.latitude = location.coordinate.latitude
                        }
                    }
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
            }
            .toolbar {
                KeyboardDismissButton(isInputActive: _isInputActive)
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button(location != nil ? "Save" : "Add") {
                        if let location = location, let timezone = timezone {
                            PersistenceManager.shared.editLocation(location: location, name: name, latitude: latitude, longitude: longitude, timezone: timezone.identifier, context: context)
                            dismiss()
                        } else {
                            if let latitude = latitude, let longitude = longitude, let timezone = timezone {
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
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Fill in every parameter")
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
