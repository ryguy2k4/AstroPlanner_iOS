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
    @Query(sort: [SortDescriptor(\SavedLocation.name, order: .forward)]) var locationList: [SavedLocation]
    @Binding var entry: JournalEntry
    
    init(entry: Binding<JournalEntry>) {
        self._entry = entry
    }
    
    var body: some View {
        ScrollView {
            Text("Entry Editor Placeholder")
//            HStack {
//                VStack(alignment: .leading) {
//                    // Target Field (popover innovation)
//                    Section {
//                        HStack {
//                            if let target = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == targetID}) {
//                                Text(target.defaultName)
//                            } else {
//                                Text("No Match")
//                                    .foregroundColor(.red)
//                            }
//                            TargetIDSearchField(searchText: $targetID)
//                        }
//                    } header: {
//                        Text("Target")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            .padding(.top)
//                    }
//                    
//                    // Setup Interval Pickers
//                    Section {
//                        if let setupInterval = entry.setupInterval {
//                            Text("\(setupInterval.start.formatted(date: .numeric, time: .standard))")
//                            Text("\(setupInterval.end.formatted(date: .numeric, time: .standard))")
//                        }
//                        //                    DatePicker("Start", selection: $entry.date, displayedComponents: .date)
//                        //                        .datePickerStyle(.field)
//                        //                    DatePicker("End", selection: $entry.date, displayedComponents: .date)
//                        //                        .datePickerStyle(.field)
//                    } header: {
//                        Text("Setup Interval")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            .padding(.top)
//                    }
//                    
//                    // Imaging Interval Pickers
//                    Section {
//                        if let imagingInterval = entry.imagingInterval {
//                            Text("\(imagingInterval.start.formatted(date: .numeric, time: .standard))")
//                            Text("\(imagingInterval.end.formatted(date: .numeric, time: .standard))")
//                        }
//                    } header: {
//                        Text("Imaging Interval")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            .padding(.top)
//                    }
//                    
//                    // Location Picker
//                    Section {
//                        Picker("", selection: $location) {
//                            ForEach(Array(locationList.enumerated()), id: \.element) { index, location in
//                                Text(location.name).tag(location)
//                            }
//                        }
//                        .frame(width: 300)
//                    } header: {
//                        Text("Location")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            .padding(.top)
//                    }
//                    
//                    // Gear Picker
//                    
//                    // WeatherKit Data
//                    if let weather = entry.weather {
//                        Section {
//                            Text("Temp: \(weather.map({$0.temperature.converted(to: .fahrenheit).value}).mean())")
//                            Text("Wind: \(weather.map({$0.wind.speed.converted(to: .milesPerHour).value}).mean())")
//                            Text("Dew Point: \(weather.map({$0.dewPoint.converted(to: .fahrenheit).value}).mean())")
//                            Text("Cloud Cover: \(weather.map({$0.cloudCover}).mean())")
//                            Text("Moon Illumination: :/")
//                        } header: {
//                            Label("Weather", systemImage: "checkmark.shield")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                                .padding(.top)
//                        }
//                    } else if let imagingInterval = entry.imagingInterval {
//                        Section {
//                            Button("Fetch Weather") {
//                                Task {
//                                    if let forecast = try? await WeatherService().weather(for: .init(latitude: 41.904, longitude: -88.286), including: .hourly(startDate: imagingInterval.start, endDate: imagingInterval.end)) {
//                                        entry.weather = forecast.forecast
//                                    }
//                                    entry.moonIllumination = Moon.getMoonIllumination(date: imagingInterval.start, timezone: .current)
//                                }
//                            }
//                        } header: {
//                            Text("Weather")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                                .padding(.top)
//                        }
//                    }
//                    
//                    //Scores
//                    if let seasonScore = entry.seasonScore, let visibilityScore = entry.visibilityScore{
//                        Section {
//                            Text("Season Score: \(seasonScore)")
//                            Text("Visibility Score: \(visibilityScore)")
//                            
//                        } header: {
//                            Label("Scores", systemImage: "checkmark.shield")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                                .padding(.top)
//                        }
//                    } else if let imagingInterval = entry.imagingInterval {
//                        Section {
//                            Button("Calculate Scores") {
//                                Task {
//                                    let home = Location(current: .init(latitude: 41.904, longitude: -88/286))
//                                    let sundata = Sun.sol.getNextInterval(location: home, date: imagingInterval.start)
//                                    if let target = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == targetID}) {
//                                        entry.seasonScore = target.getSeasonScore(at: home, on: imagingInterval.start, sunData: sundata)
//                                        entry.visibilityScore = target.getVisibilityScore(at: home, viewingInterval: sundata.ATInterval, sunData: sundata, limitingAlt: 20)
//                                    }
//                                }
//                            }
//                        } header: {
//                            Text("Weather")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                                .padding(.top)
//                        }
//                    }
//                    
//                    // Image Plan Fields
//
//                    Section {
//                        HStack {
//                            if let imagePlan = entry.imagePlan {
//                                ForEach(imagePlan, id: \.self) { sequence in
//                                    VStack {
//                                        Text(sequence.filterName)
//                                        Text("\(sequence.progressExposureCount)/\(sequence.totalExposureCount)")
//                                        Text("\(sequence.exposureTime)")
//                                    }
//                                }
//                            }
//                            ForEach(0..<plan.count, id: \.self) { index in
//                                VStack {
//                                    TextField("Filter Name", text: $plan[index].filterName)
//                                        .frame(maxWidth: 105)
//                                    HStack {
//                                        TextField("Progress", value: $plan[index].progressExposureCount, format: .number)
//                                            .frame(maxWidth: 50)
//                                        Text("/")
//                                        TextField("Total", value: $plan[index].totalExposureCount, format: .number)
//                                            .frame(maxWidth: 50)
//                                    }
//                                    TextField("Exposure", value: $plan[index].exposureTime, format: .number)
//                                        .frame(maxWidth: 105)
//                                }
//                            }
//                            Button("Add Sequence") {
//                                plan.append(.init(filterName: "<filter>", exposureTime: 300, totalExposureCount: 20, progressExposureCount: 20))
//                            }
//                        }
//                    } header: {
//                        Text("Image Plan")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                            .padding(.top)
//                    }
//                    Spacer()
//                }
//                .padding()
//                .onDisappear() {
//                    entry.targetID = UUID(uuidString: targetID)!
//                    let target = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == targetID})
//                    entry.location = location
//                    entry.imagePlan = plan
//                }
//                Spacer()
//            }
        }
    }
}
