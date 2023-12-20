//
//  EntryEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 11/27/23.
//

import SwiftUI
import SwiftData
import WeatherKit

struct EntryEditor: View {
    @Binding var entry: JournalEntry
    @State var locationEditor = false
    
    init(entry: Binding<JournalEntry>) {
        self._entry = entry
    }
    
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    // Setup Interval Pickers
                    EntrySection(title: "Setup Interval") {
                        if let setupInterval = entry.setupInterval {
                            Text("\(setupInterval.start.formatted(date: .numeric, time: .standard))")
                            Text("\(setupInterval.end.formatted(date: .numeric, time: .standard))")
                        } else {
                            Text("nil setup interval")
                        }
                    } editor: {
                        Text("Placeholder")
                    }
                    
                    // Location Picker
                    EntrySection(title: "Location") {
                        if let location = entry.location {
                            Text("\(location.latitude)")
                            Text("\(location.longitude)")
                        } else {
                            Text("nil location")
                        }
                    } editor: {
                        JournalLocationEditor(location: $entry.location)
                    }
                    
                    // Gear Picker
                    EntrySection(title: "Gear") {
                        if let gear = entry.gear {
                            Text("\(gear.focalLength)")
                            Text("\(gear.pixelSize)")
                        } else {
                            Text("nil gear")
                        }
                    } editor: {
                        Text("Placeholder")
                    }
                    
                    // WeatherKit Data
                    EntrySection(title: "Weather") {
                        if let weather = entry.weather {
                            Text("Temp: \(weather.map({$0.temperature.converted(to: .fahrenheit).value}).mean())")
                            Text("Wind: \(weather.map({$0.wind.speed.converted(to: .milesPerHour).value}).mean())")
                            Text("Dew Point: \(weather.map({$0.dewPoint.converted(to: .fahrenheit).value}).mean())")
                            Text("Cloud Cover: \(weather.map({$0.cloudCover}).mean())")
                            Text("Moon Illumination: \(entry.moonIllumination ?? 0)")
                        } else {
                            Text("nil weather")
                        }
                    } editor: {
                        Text("Placeholder")
                    }
                    
                    // Target Sets
                    HStack {
                        ForEach(entry.targetSet, id: \.target?.targetID.name) { targetSet in
                            // Target Field (popover innovation)
                            VStack {
                                Section {
                                    HStack {
                                        Text(targetSet.target!.targetID.name)
                                        //                            TargetIDSearchField(searchText: $targetID)
                                    }
                                } header: {
                                    Text("Target")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.top)
                                }
                                
                                // Imaging Interval Pickers
                                Section {
                                    if let imagingInterval = targetSet.imagingInterval {
                                        Text("\(imagingInterval.start.formatted(date: .numeric, time: .standard))")
                                        Text("\(imagingInterval.end.formatted(date: .numeric, time: .standard))")
                                    }
                                } header: {
                                    Text("Imaging Interval")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.top)
                                }
                                
                                // Scores
                                Section {
                                    if let seasonScore = targetSet.seasonScore, let visibilityScore = targetSet.visibilityScore {
                                        Text("Season Score: \(seasonScore)")
                                        Text("Visibility Score: \(visibilityScore)")
                                    }
                                    
                                } header: {
                                    Text("Scores")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.top)
                                }
                                
                                // Image Plan Fields
                                Section {
                                    HStack {
                                        if let imagePlan = targetSet.imagePlan {
                                            ForEach(imagePlan, id: \.filterName) { sequence in
                                                VStack {
                                                    Text(sequence.filterName!)
                                                    Text("\(sequence.numCaptured ?? 0)")
                                                    Text("\(sequence.exposureTime ?? 0)")
                                                }
                                            }
                                            NavigationLink("Test") {
                                                SequenceViewer(imagePlan: imagePlan, sidebarItem: imagePlan.first!)
                                            }
                                        }
                                    }
                                } header: {
                                    Text("Image Plan")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.top)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
    }
}

struct SequenceViewer: View {
    let imagePlan: [JournalImageSequence]
    @State var sidebarItem: JournalImageSequence
    var body: some View {
        NavigationSplitView {
            List(imagePlan, id: \.hashValue, selection: $sidebarItem) { plan in
                Text(plan.filterName!)
            }
        } detail: {
            VStack {
                Text(sidebarItem.filterName!)
                Text("\(sidebarItem.numCaptured ?? 0)")
                Text("\(sidebarItem.exposureTime ?? 0)")
            }
        }
    }
}

struct EntrySection<Modal: View, Content: View>: View {
    @State var editorPresented = false
    let title: String
    private var editor: Modal
    private var content: Content

    init(title: String, @ViewBuilder content: () -> Content, @ViewBuilder editor: () -> Modal) {
        self.title = title
        self.content = content()
        self.editor = editor()
    }
    var body: some View {
        Section {
            content
        } header: {
            HStack {
                Button {
                    editorPresented = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.top)
        }
        .sheet(isPresented: $editorPresented) {
            editor
        }
    }
}

struct JournalLocationEditor: View {
    @Environment(\.dismiss) var dismiss
    @Binding var location: JournalLocation?
    var body: some View {
        VStack {
            if let location = Binding($location) {
                TextField("Latitude", value: location.latitude, format: .number)
                TextField("Longitude", value: location.longitude, format: .number)
            } else {
                ProgressView("Wait")
                    .onAppear {
                        self.location = JournalLocation(latitude: 0, longitude: 0, timezone: "GMT")
                    }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
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
