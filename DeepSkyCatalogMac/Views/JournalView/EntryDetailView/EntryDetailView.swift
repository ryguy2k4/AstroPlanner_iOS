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
                            LabeledText(label: "Start", value: "\(setupInterval.start.formatted(date: .numeric, time: .standard))")
                            LabeledText(label: "End", value: "\(setupInterval.end.formatted(date: .numeric, time: .standard))")
                        } else {
                            Text("nil setup interval")
                        }
                    } editor: {
                        EntryIntervalEditor(interval: $entry.setupInterval)
                    }.disabled(!editing)
                    
                    // Location Picker
                    EntrySection(title: "Location") {
                        if let location = entry.location {
                            LabeledText(label: "Name:", value: "\(location.name)")
                            LabeledText(label: "Latitude:", value: "\(location.latitude.formatDecimal())")
                            LabeledText(label: "Longitude:", value: "\(location.longitude.formatDecimal())")
                            LabeledText(label: "Timezone:", value: "\(location.timezone.identifier)")
                            LabeledText(label: "Elevation:", value: location.elevation?.description)
                            LabeledText(label: "Bortle:", value: location.bortle?.description)
                        } else {
                            Text("nil location")
                        }
                    } editor: {
                        EntryLocationEditor(location: $entry.location)
                    }.disabled(!editing)
                    
                    // Gear Picker
                    EntrySection(title: "Gear") {
                        if let gear = entry.gear {
                            LabeledText(label: "Telescope:", value: gear.telescopeName)
                            LabeledText(label: "Focal Length:", value: gear.focalLength?.formatDecimal())
                            LabeledText(label: "Camera:", value: gear.cameraName)
                            LabeledText(label: "Pixel Size:", value: gear.pixelSize?.formatDecimal())
                            LabeledText(label: "Length:", value: gear.resolutionLength?.description)
                            LabeledText(label: "Width:", value: gear.resolutionWidth?.description)
                            LabeledText(label: "Filter Wheel:", value: gear.filterWheelName)
                            LabeledText(label: "Mount:", value: gear.mountName)
                        } else {
                            Text("nil gear")
                        }
                    } editor: {
                        EntryGearEditor(gear: $entry.gear)
                    }.disabled(!editing)
                    
                    // WeatherKit Data
                    EntrySection(title: "Weather") {
                        if let weather = entry.weather, let moonIllumination = entry.moonIllumination {
                            LabeledText(label: "Temp:", value: "\(weather.map({$0.temperature.converted(to: .fahrenheit).value}).mean().formatDecimal())")
                            LabeledText(label: "Wind:", value: "\(weather.map({$0.wind.speed.converted(to: .milesPerHour).value}).mean().formatDecimal())")
                            LabeledText(label: "Dew Point:", value: "\(weather.map({$0.dewPoint.converted(to: .fahrenheit).value}).mean().formatDecimal())")
                            LabeledText(label: "Cloud Cover:", value: "\(weather.map({$0.cloudCover}).mean().percent())")
                            LabeledText(label: "Moon Illumination:", value: "\(moonIllumination.percent())")
                        } else {
                            Text("nil weather")
                        }
                    }.disabled(true)
                    
                    // Target
                    EntrySection(title: "Target") {
                        if let target = entry.target {
                            LabeledText(label: "Name:", value: target.targetID?.name)
                            LabeledText(label: "Center RA:", value: target.centerRA?.description)
                            LabeledText(label: "Center DEC:", value: target.centerDEC?.description)
                            LabeledText(label: "Rotation:", value: target.rotation?.description)
                        } else {
                            Text("nil target")
                        }
                    } editor: {
                        EntryTargetEditor(target: $entry.target)
                    }.disabled(!editing)
                    
                    // Imaging Interval Pickers
                    EntrySection(title: "Imaging Interval") {
                        if let imagingInterval = entry.imagingInterval {
                            LabeledText(label: "Start", value: "\(imagingInterval.start.formatted(date: .numeric, time: .standard))")
                            LabeledText(label: "End", value: "\(imagingInterval.end.formatted(date: .numeric, time: .standard))")
                        } else {
                            Text("nil imaging interval")
                        }
                    } editor: {
                        EntryIntervalEditor(interval: $entry.imagingInterval)
                    }.disabled(!editing)
                    
                    // Scores
                    EntrySection(title: "Scores") {
                        if let seasonScore = entry.seasonScore, let visibilityScore = entry.visibilityScore {
                            LabeledText(label: "Season Score:", value: "\(seasonScore.percent())")
                            LabeledText(label: "Visibility Score:", value: "\(visibilityScore.percent())")
                        } else {
                            Text("nil scores")
                        }
                    }.disabled(true)
                    
                    // Image Plan Fields
                    EntrySection(title: "Image Plan") {
                        VStack {
                            if let imagePlan = entry.imagePlan {
                                Grid {
                                    // Header Row
                                    GridRow {
                                        Text("Filter")
                                        Text("Exposure")
                                        Text("Binning")
                                        Text("Gain")
                                        Text("Offset")
                                        Text("Usable")
                                        Text("Captured")
                                    }
                                    .fontWeight(.semibold)
                                    // Sequence Rows
                                    ForEach(imagePlan) { sequence in
                                        GridRow {
                                            JournalDetailOptionalValueText(value: sequence.filterName)
                                            JournalDetailOptionalValueText(value: sequence.exposureTime?.description)
                                            Text("\(sequence.binning ?? 1)x\(sequence.binning ?? 1)")
                                            JournalDetailOptionalValueText(value: sequence.gain?.description)
                                            JournalDetailOptionalValueText(value: sequence.offset?.description)
                                            JournalDetailOptionalValueText(value: sequence.numUsable?.description)
                                            JournalDetailOptionalValueText(value: sequence.numCaptured?.description)
                                        }
                                    }
                                }
                            }
                        }
                    } editor: {
                        EntryPlanEditor(plan: $entry.imagePlan)
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
            .onChange(of: entry.location) { _, newLocation in
                Task {
                    if let newLocation = newLocation, let setupInterval = entry.setupInterval {
                        let newWeather = try? await WeatherService().weather(for: newLocation.clLocation, including: .hourly(startDate: setupInterval.start, endDate: setupInterval.end))
                        entry.weather = newWeather?.forecast
                        
                        if case let .catalog(id) = entry.target?.targetID, let target = DeepSkyTargetList.allTargets.first(where: {$0.id == id}) {
                            let sunData = Sun.sol.getNextInterval(location: newLocation, date: setupInterval.start.startOfLocalDay(timezone: newLocation.timezone))
                            entry.visibilityScore = target.getVisibilityScore(at: newLocation, viewingInterval: setupInterval, sunData: sunData, limitingAlt: 0)
                            entry.seasonScore = target.getSeasonScore(at: newLocation, on: setupInterval.start.startOfLocalDay(timezone: newLocation.timezone), sunData: sunData)
                        } else {
                            entry.visibilityScore = nil
                            entry.seasonScore = nil
                        }
                    } else {
                        entry.weather = nil
                        entry.visibilityScore = nil
                        entry.seasonScore = nil
                    }
                }
            }
            .onChange(of: entry.setupInterval) { _, newSetupInterval in
                Task {
                    if let newSetupInterval = newSetupInterval, let location = entry.location {
                        let newWeather = try? await WeatherService().weather(for: location.clLocation, including: .hourly(startDate: newSetupInterval.start, endDate: newSetupInterval.end))
                        entry.weather = newWeather?.forecast
                        
                        if case let .catalog(id) = entry.target?.targetID, let target = DeepSkyTargetList.allTargets.first(where: {$0.id == id}) {
                            let sunData = Sun.sol.getNextInterval(location: location, date: newSetupInterval.start.startOfLocalDay(timezone: location.timezone))
                            entry.visibilityScore = target.getVisibilityScore(at: location, viewingInterval: newSetupInterval, sunData: sunData, limitingAlt: 0)
                            entry.seasonScore = target.getSeasonScore(at: location, on: newSetupInterval.start.startOfLocalDay(timezone: location.timezone), sunData: sunData)
                        } else {
                            entry.visibilityScore = nil
                            entry.seasonScore = nil
                        }
                    } else {
                        entry.weather = nil
                        entry.visibilityScore = nil
                        entry.seasonScore = nil
                    }
                }
            }
            .onChange(of: entry.target?.targetID) { _, newTarget in
                Task {
                    if case let .catalog(id) = newTarget, let target = DeepSkyTargetList.allTargets.first(where: {$0.id == id}), let setupInterval = entry.setupInterval, let location = entry.location {
                        let sunData = Sun.sol.getNextInterval(location: location, date: setupInterval.start.startOfLocalDay(timezone: location.timezone))
                        entry.visibilityScore = target.getVisibilityScore(at: location, viewingInterval: setupInterval, sunData: sunData, limitingAlt: 0)
                        entry.seasonScore = target.getSeasonScore(at: location, on: setupInterval.start.startOfLocalDay(timezone: location.timezone), sunData: sunData)
                    } else {
                        entry.visibilityScore = nil
                        entry.seasonScore = nil
                    }
                }
            }
        }
    }
}

struct LabeledText: View {
    let label: String
    let value: String?
    var body: some View {
        HStack {
            Text(label)
                .bold()
            JournalDetailOptionalValueText(value: value)
        }
    }
}

struct JournalDetailOptionalValueText: View {
    let value: String?
    var body: some View {
        Text(value ?? "Unspecified")
            .foregroundStyle(value == nil ? .red : .primary)
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
