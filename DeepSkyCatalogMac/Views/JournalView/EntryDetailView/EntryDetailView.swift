//
//  EntryDetailView.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 11/27/23.
//

import SwiftUI
import SwiftData
import WeatherKit

struct EntryDetailView: View {
    @ObservedObject var entry: JournalEntry
    @State var locationEditor = false
    @State var editing = true
    
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
                        EntryIntervalEditor(interval: $entry.setupInterval)
                    }.disabled(!editing)
                    
                    // Location Picker
                    EntrySection(title: "Location") {
                        if let location = entry.location {
                            Text("\(location.latitude.formatDecimal())")
                            Text("\(location.longitude.formatDecimal())")
                        } else {
                            Text("nil location")
                        }
                    } editor: {
                        EntryLocationEditor(location: $entry.location)
                    }.disabled(!editing)
                    
                    // Gear Picker
                    EntrySection(title: "Gear") {
                        if let gear = entry.gear {
                            Text("\(gear.focalLength.formatDecimal())")
                            Text("\(gear.pixelSize.formatDecimal())")
                        } else {
                            Text("nil gear")
                        }
                    } editor: {
                        Text("Placeholder")
                    }.disabled(!editing)
                    
                    // WeatherKit Data
                    EntrySection(title: "Weather") {
                        if let weather = entry.weather, let moonIllumination = entry.moonIllumination {
                            Text("Temp: \(weather.map({$0.temperature.converted(to: .fahrenheit).value}).mean().formatDecimal())")
                            Text("Wind: \(weather.map({$0.wind.speed.converted(to: .milesPerHour).value}).mean().formatDecimal())")
                            Text("Dew Point: \(weather.map({$0.dewPoint.converted(to: .fahrenheit).value}).mean().formatDecimal())")
                            Text("Cloud Cover: \(weather.map({$0.cloudCover}).mean().percent())")
                            Text("Moon Illumination: \(moonIllumination.percent())")
                        } else {
                            Text("nil weather")
                        }
                    }.disabled(true)
                    
                    // Target
                    EntrySection(title: "Target") {
                        if let target = entry.target {
                            HStack {
                                Text(target.targetID.name )
//                                TargetIDSearchField(searchText: $targetID)
                            }
                        } else {
                            Text("nil target")
                        }
                    } editor: {
                        Text("Placeholder")
                    }.disabled(!editing)
                    
                    // Imaging Interval Pickers
                    EntrySection(title: "Imaging Interval") {
                        if let imagingInterval = entry.imagingInterval {
                            Text("\(imagingInterval.start.formatted(date: .numeric, time: .standard))")
                            Text("\(imagingInterval.end.formatted(date: .numeric, time: .standard))")
                        } else {
                            Text("nil imaging interval")
                        }
                    } editor: {
                        EntryIntervalEditor(interval: $entry.imagingInterval)
                    }.disabled(!editing)
                    
                    // Scores
                    EntrySection(title: "Scores") {
                        if let seasonScore = entry.seasonScore, let visibilityScore = entry.visibilityScore {
                            Text("Season Score: \(seasonScore.percent())")
                            Text("Visibility Score: \(visibilityScore.percent())")
                        } else {
                            Text("nil scores")
                        }
                    }.disabled(true)
                    
                    // Image Plan Fields
                    EntrySection(title: "Image Plan") {
                        HStack {
                            if let imagePlan = entry.imagePlan {
                                ForEach(imagePlan, id: \.filterName) { sequence in
                                    VStack {
                                        Text(sequence.filterName!)
                                        Text("\(sequence.numCaptured ?? 0)")
                                        Text("\(sequence.exposureTime ?? 0)")
                                    }
                                }
                            }
                        }
                    } editor: {
                        Text("Placeholder")
                    }.disabled(!editing)
                    Spacer()
                }
                .padding(.leading)
                Spacer()
            }
            .toolbar {
                ToolbarItem {
                    Button("Edit") {
                        editing.toggle()
                    }
                }
            }
        }
    }
}

struct EntrySection<Modal: View, Content: View>: View {
    @Environment(\.isEnabled) var isEnabled
    @State var editorPresented = false
    let title: String
    private var editor: Modal
    private var content: Content

    init(title: String, @ViewBuilder content: () -> Content, @ViewBuilder editor: () -> Modal = { EmptyView() }) {
        self.title = title
        self.content = content()
        self.editor = editor()
    }
    var body: some View {
        Section {
            content
        } header: {
            HStack {
                if isEnabled {
                    Button {
                        editorPresented = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
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
