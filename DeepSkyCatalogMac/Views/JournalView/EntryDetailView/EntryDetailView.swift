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
                            } else {
                                Label("No Associated Image Plan", systemImage: "slash.circle")
                                    .foregroundStyle(Color.red)
                            }
                        }
                    } editor: {
                        EntryPlanEditor(plan: $entry.imagePlan)
                    }.disabled(!editing)
                    
                    // Setup Interval Pickers
                    EntrySection(title: "Setup Interval") {
                        if let setupInterval = entry.setupInterval {
                            LabeledText(label: "Start", value: "\(setupInterval.start.formatted(date: .numeric, time: .standard))")
                            LabeledText(label: "End", value: "\(setupInterval.end.formatted(date: .numeric, time: .standard))")
                        } else {
                            Label("No Associated Setup Interval", systemImage: "slash.circle")
                                .foregroundStyle(Color.red)
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
                            Label("No Associated Location", systemImage: "slash.circle")
                                .foregroundStyle(Color.red)
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
                            Label("No Associated Gear", systemImage: "slash.circle")
                                .foregroundStyle(Color.red)
                        }
                    } editor: {
                        EntryGearEditor(gear: $entry.gear)
                    }.disabled(!editing)
                    
                    // WeatherKit Data
                    EntryRefreshSection(title: "Weather") {
                        if let weather = entry.weather, let moonIllumination = entry.moonIllumination {
                            LabeledText(label: "Temp:", value: "\(weather.map({$0.temperatureF}).mean().formatDecimal())")
                            LabeledText(label: "Wind:", value: "\(weather.map({$0.windMPH}).mean().formatDecimal())")
                            LabeledText(label: "Dew Point:", value: "\(weather.map({$0.dewPointF}).mean().formatDecimal())")
                            LabeledText(label: "Cloud Cover:", value: "\(weather.map({$0.cloudCover}).mean().percent())")
                            LabeledText(label: "Moon Illumination:", value: "\(moonIllumination.percent())")
                        } else {
                            Label("No Associated Weather Data", systemImage: "slash.circle")
                                .foregroundStyle(Color.red)
                        }
                    } refreshAction: {
                        Task {
                            if let location = entry.location, let interval = entry.setupInterval ?? entry.imagingInterval {
                                let newWeather = try? await WeatherService().weather(for: location.clLocation, including: .hourly(startDate: interval.start, endDate: interval.end))
                                entry.weather = newWeather?.forecast.map({JournalEntry.JournalHourWeather(weather: $0)})
                            }
                        }
                    }.disabled(!editing)
                    
                    // Target
                    EntrySection(title: "Target") {
                        if let target = entry.target {
                            if case .catalog(_) = entry.target?.targetID {
                                Text("Catalog Match")
                                    .foregroundStyle(Color.accentColor)
                            } else {
                                Text("No Catalog Match")
                                    .foregroundStyle(Color.primary)
                                    .font(.body.italic())
                            }
                            LabeledText(label: "Name:", value: target.targetID?.name)
                            LabeledText(label: "Center RA:", value: target.centerRA?.description)
                            LabeledText(label: "Center DEC:", value: target.centerDEC?.description)
                            LabeledText(label: "Rotation:", value: target.rotation?.description)
                        } else {
                            Label("No Associated Target", systemImage: "slash.circle")
                                .foregroundStyle(Color.red)
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
                            Label("No Associated Imaging Interval", systemImage: "slash.circle")
                                .foregroundStyle(Color.red)
                        }
                    } editor: {
                        EntryIntervalEditor(interval: $entry.imagingInterval)
                    }.disabled(!editing)
                    
                    // Scores
                    EntryRefreshSection(title: "Scores") {
                        if let seasonScore = entry.seasonScore, let visibilityScore = entry.visibilityScore {
                            LabeledText(label: "Season Score:", value: "\(seasonScore.percent())")
                            LabeledText(label: "Visibility Score:", value: "\(visibilityScore.percent())")
                        } else {
                            Label("No Associated Scores", systemImage: "slash.circle")
                                .foregroundStyle(Color.red)
                        }
                    } refreshAction: {
                        if let ra = entry.target?.centerRA, let dec = entry.target?.centerDEC, let interval = entry.setupInterval ?? entry.imagingInterval, let location = entry.location {
                            let sunData = Sun.sol.getNextInterval(location: location, date: interval.start.startOfLocalDay(timezone: location.timezone))
                            entry.visibilityScore = DeepSkyTarget.getVisibilityScore(at: location, viewingInterval: sunData.ATInterval, limitingAlt: 0, ra: ra, dec: dec)
                            entry.seasonScore = DeepSkyTarget.getSeasonScore(at: location, on: interval.start.startOfLocalDay(timezone: location.timezone), sunData: sunData, ra: ra, dec: dec)
                        } else {
                            entry.visibilityScore = nil
                            entry.seasonScore = nil
                        }
                    }.disabled(!editing)
                    
                    // Tags
                    EntrySection(title: "Tags") {
                        if entry.tags.isEmpty {
                            Label("No Tags", systemImage: "slash.circle")
                        } else {
                            ForEach(Array(entry.tags), id: \.rawValue) { tag in
                                Label(tag.rawValue, systemImage: "tag")
                            }
                        }
                    } editor: {
                        EntryTagsEditor(tags: $entry.tags)
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
                    if let newLocation = newLocation, let interval = entry.setupInterval ?? entry.imagingInterval {
                        let newWeather = try? await WeatherService().weather(for: newLocation.clLocation, including: .hourly(startDate: interval.start, endDate: interval.end))
                        entry.weather = newWeather?.forecast.map({JournalEntry.JournalHourWeather(weather: $0)})
                        
                        if let ra = entry.target?.centerRA, let dec = entry.target?.centerDEC {
                            let sunData = Sun.sol.getNextInterval(location: newLocation, date: interval.start.startOfLocalDay(timezone: newLocation.timezone))
                            entry.visibilityScore = DeepSkyTarget.getVisibilityScore(at: newLocation, viewingInterval: sunData.ATInterval, limitingAlt: 0, ra: ra, dec: dec)
                            entry.seasonScore = DeepSkyTarget.getSeasonScore(at: newLocation, on: interval.start.startOfLocalDay(timezone: newLocation.timezone), sunData: sunData, ra: ra, dec: dec)
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
                        entry.weather = newWeather?.forecast.map({JournalEntry.JournalHourWeather(weather: $0)})
                        
                        if let ra = entry.target?.centerRA, let dec = entry.target?.centerDEC, let location = entry.location {
                            let sunData = Sun.sol.getNextInterval(location: location, date: newSetupInterval.start.startOfLocalDay(timezone: location.timezone))
                            entry.visibilityScore = DeepSkyTarget.getVisibilityScore(at: location, viewingInterval: sunData.ATInterval, limitingAlt: 0, ra: ra, dec: dec)
                            entry.seasonScore = DeepSkyTarget.getSeasonScore(at: location, on: newSetupInterval.start.startOfLocalDay(timezone: location.timezone), sunData: sunData, ra: ra, dec: dec)
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
                    if let ra = entry.target?.centerRA, let dec = entry.target?.centerDEC, let interval = entry.setupInterval ?? entry.imagingInterval, let location = entry.location {
                        let sunData = Sun.sol.getNextInterval(location: location, date: interval.start.startOfLocalDay(timezone: location.timezone))
                        entry.visibilityScore = DeepSkyTarget.getVisibilityScore(at: location, viewingInterval: sunData.ATInterval, limitingAlt: 0, ra: ra, dec: dec)
                        entry.seasonScore = DeepSkyTarget.getSeasonScore(at: location, on: interval.start.startOfLocalDay(timezone: location.timezone), sunData: sunData, ra: ra, dec: dec)
                    } else {
                        entry.visibilityScore = nil
                        entry.seasonScore = nil
                    }
                }
            }
            .onChange(of: entry.imagePlan) { _, newPlan in
                // Consolidate same filter/gain/exposure
                if let newPlan = newPlan {
                    var consolidatedPlans: [JournalEntry.JournalImageSequence] = []
                    var consolidatedPlansCount = 0
                    var remainingPlans: [JournalEntry.JournalImageSequence] = newPlan
                    while !remainingPlans.isEmpty {
                        consolidatedPlans.append(remainingPlans.remove(at: 0))
                        var offset = 0
                        for i in remainingPlans.indices {
                            if remainingPlans[i-offset].filterName == consolidatedPlans[consolidatedPlansCount].filterName &&
                                remainingPlans[i-offset].exposureTime == consolidatedPlans[consolidatedPlansCount].exposureTime &&
                                remainingPlans[i-offset].gain == consolidatedPlans[consolidatedPlansCount].gain {
                                if let _ = consolidatedPlans[consolidatedPlansCount].numUsable {
                                    consolidatedPlans[consolidatedPlansCount].numUsable! += (remainingPlans[i-offset].numUsable ?? 0)
                                    remainingPlans.remove(at: i-offset)
                                } else {
                                    consolidatedPlans[consolidatedPlansCount].numUsable = remainingPlans[i-offset].numUsable
                                    remainingPlans.remove(at: i-offset)
                                }
                                offset += 1
                            }
                        }
                        consolidatedPlansCount += 1
                    }
                    entry.imagePlan = consolidatedPlans
                }
                
                /*
                 var groups: [[EXIFMetadata]] = []
                 var groupCount = 0
                 var remainingImages = rawMetadata
                 while !remainingImages.isEmpty {
                     groups.append([remainingImages.remove(at: 0)])
                     var offset = 0
                     for i in remainingImages.indices {
                         if remainingImages[i-offset].exposureTime == groups[groupCount].first!.exposureTime && remainingImages[i-offset].iso == groups[groupCount].first!.iso {
                             groups[groupCount].append(remainingImages.remove(at: i-offset))
                             offset += 1
                         }
                     }
                     groupCount += 1
                 }
                 */
            }
            .id(entry.id)
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

struct EntryRefreshSection<Content: View>: View {
    @Environment(\.isEnabled) var isEnabled
    let title: String
    let refreshAction: () -> Void
    private var content: Content

    init(title: String, @ViewBuilder content: () -> Content, refreshAction: @escaping () -> Void) {
        self.title = title
        self.refreshAction = refreshAction
        self.content = content()
    }
    var body: some View {
        Section {
            content
        } header: {
            HStack {
                if isEnabled {
                    Button {
                        refreshAction()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.top)
        }
    }
}
