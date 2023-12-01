//
//  EntryEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 11/27/23.
//

import SwiftUI
import WeatherKit

struct EntryEditor: View {
    @Binding var entry: JournalEntry
    @State var targetID: String
    @State var gear: JournalEntry.ImagingGear
    
    init(entry: Binding<JournalEntry>) {
        self._entry = entry
        self._targetID = State(initialValue: entry.wrappedValue.targetID.uuidString)
        self._gear = State(initialValue: entry.wrappedValue.gear ?? .zenithstar61)
    }
    
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    // Target Field (popover innovation)
                    Section {
                        HStack {
                            if let target = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == targetID}) {
                                Text(target.defaultName)
                            } else {
                                Text("No Match")
                                    .foregroundColor(.red)
                            }
                            TargetIDSearchField(searchText: $targetID)
                        }
                    } header: {
                        Text("Target")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top)
                    }
                    
                    // Setup Interval Pickers
                    Section {
                        if let setupInterval = entry.setupInterval {
                            Text("\(setupInterval.start.formatted(date: .numeric, time: .standard))")
                            Text("\(setupInterval.end.formatted(date: .numeric, time: .standard))")
                        }
                        //                    DatePicker("Start", selection: $entry.date, displayedComponents: .date)
                        //                        .datePickerStyle(.field)
                        //                    DatePicker("End", selection: $entry.date, displayedComponents: .date)
                        //                        .datePickerStyle(.field)
                    } header: {
                        Text("Setup Interval")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top)
                    }
                    
                    // Imaging Interval Pickers
                    Section {
                        if let imagingInterval = entry.imagingInterval {
                            Text("\(imagingInterval.start.formatted(date: .numeric, time: .standard))")
                            Text("\(imagingInterval.end.formatted(date: .numeric, time: .standard))")
                        }
                    } header: {
                        Text("Imaging Interval")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top)
                    }
                    
                    // Location Picker
                    
                    // Gear Picker
                    Section {
                        Picker("", selection: $gear) {
                            ForEach(JournalEntry.ImagingGear.allCases, id: \.hashValue) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .frame(width: 300)
                    } header: {
                        Text("Gear")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top)
                    }
                    
                    // Legacy Weather Fields
                    if let legacyWeather = entry.legacyWeather {
                        Section {
                            Text("TempC: \(legacyWeather.tempC)")
                            Text("TempF: \(legacyWeather.tempF)")
                            Text("Wind: \(legacyWeather.wind)")
                        } header: {
                            Text("Legacy Weather")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.top)
                        }
                    }
                    
                    // WeatherKit Data
                    if let weather = entry.weather {
                        Section {
                            Text("Temp: \(weather.tempC)")
                            Text("Wind: \(weather.wind)")
                            Text("Dew Point: \(weather.dewPoint)")
                            Text("Cloud Cover: \(weather.cloudCover)")
                            Text("Moon Illumination: \(weather.moonIllumination)")
                        } header: {
                            Label("Weather", systemImage: "checkmark.shield")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.top)
                        }
                    } else if let imagingInterval = entry.imagingInterval {
                        Section {
                            Button("Fetch Weather") {
                                Task {
                                    if let forecast = try? await WeatherService().weather(for: .init(latitude: 41.904, longitude: -88.286), including: .hourly(startDate: imagingInterval.start, endDate: imagingInterval.end)) {
                                        entry.weather = JournalEntry.JournalWeather(forecast: forecast, moonIllumination: Moon.getMoonIllumination(date: entry.setupInterval!.start, timezone: .current))
                                    }
                                }
                            }
                        } header: {
                            Text("Weather")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.top)
                        }
                    }
                    
                    //Scores
                    if let seasonScore = entry.seasonScore, let visibilityScore = entry.visibilityScore{
                        Section {
                            Text("Season Score: \(seasonScore)")
                            Text("Visibility Score: \(visibilityScore)")
                            
                        } header: {
                            Label("Scores", systemImage: "checkmark.shield")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.top)
                        }
                    } else if let imagingInterval = entry.imagingInterval {
                        Section {
                            Button("Calculate Scores") {
                                Task {
                                    let home = Location(current: .init(latitude: 41.904, longitude: -88/286))
                                    let sundata = Sun.sol.getNextInterval(location: home, date: imagingInterval.start)
                                    if let target = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == targetID}) {
                                        entry.seasonScore = target.getSeasonScore(at: home, on: imagingInterval.start, sunData: sundata)
                                        entry.visibilityScore = target.getVisibilityScore(at: home, viewingInterval: sundata.ATInterval, sunData: sundata, limitingAlt: 20)
                                    }
                                }
                            }
                        } header: {
                            Text("Weather")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.top)
                        }
                    }
                    
                    // Image Plan Fields
                    if let plan = entry.imagePlan {
                        Section {
                            HStack {
                                ForEach(plan, id: \.self) { sequence in
                                    VStack {
                                        Text(sequence.filterName)
                                        Text("\(sequence.progressExposureCount)/\(sequence.totalExposureCount)")
                                        Text("\(sequence.exposureTime)")
                                        
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
                    Spacer()
                }
                .padding()
                .onDisappear() {
                    entry.targetID = UUID(uuidString: targetID)!
                    entry.gear = gear
                }
                Spacer()
            }
        }
    }
}

extension Array where Element == Double {
    func mean() -> Double {
        var sum = 0.0
        for item in self {
            sum += item
        }
        return sum / Double(self.count)
    }
}
