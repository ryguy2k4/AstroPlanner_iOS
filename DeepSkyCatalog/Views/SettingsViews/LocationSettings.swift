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
    @State private var timezone: Int16 = -6
    let location: SavedLocation?
    
    var body: some View {
        NavigationView {
            Form {
                ConfigSection(footer: "Enter the numbers in decimal form, not degrees, minutes, and seconds") {
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
                    Text("Timezone (GMT offset): ")
                    Picker("Timezone: \(timezone)", selection: $timezone) {
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
                            self.longitude = location.coordinate.longitude
                            self.latitude = location.coordinate.latitude
                        }
                    }
                }
            }
            .toolbar {
                KeyboardDismissButton(isInputActive: _isInputActive)
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button(location != nil ? "Save" : "Add") {
                        if let location = location {
                            PersistenceManager.shared.editLocation(location: location, name: name, latitude: latitude, longitude: longitude, timezone: timezone, context: context)
                            dismiss()
                        } else {
                            if let latitude = latitude, let longitude = longitude {
                                PersistenceManager.shared.addLocation(name: name, latitude: latitude, longitude: longitude, timezone: timezone, context: context)
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
                    self.timezone = location.timezone
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
