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
    
    init(entry: Binding<JournalEntry>) {
        self._entry = entry
        self._targetID = State(initialValue: entry.wrappedValue.targetID.uuidString)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // Date Picker
                Section {
                    DatePicker("Date", selection: $entry.date, displayedComponents: .date)
                        .datePickerStyle(.field)
                } header: {
                    Text("Date")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.top)
                }
                
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
                        Label("Weather Data", systemImage: "checkmark.shield")
                        Text("Temp: \(weather.forecast.map({$0.temperature}).randomElement()?.description ?? "No Data")")
                        Text("Wind: \(weather.forecast.map({$0.wind}).randomElement().debugDescription )")
                    } header: {
                        Text("Legacy Weather")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top)
                    }
                } else if let imagingInterval = entry.imagingInterval {
                    Section {
                        Button("Fetch Weather") {
                            Task {
                                entry.weather = try? await WeatherService().weather(for: .init(latitude: 41.904, longitude: -88.286), including: .hourly(startDate: imagingInterval.start, endDate: imagingInterval.end))
                            }
                        }
                    } header: {
                        Text("Legacy Weather")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top)
                    }
                }
                
                // Image Plan Fields
                if let plan = entry.imagePlan {
                    Section {
                        HStack {
                            ForEach(plan.captureSequences, id: \.self) { sequence in
                                VStack {
                                    Text(sequence.imageType)
                                    Text(sequence.filterType.name)
                                    Text("\(sequence.totalExposureCount)")
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
            Spacer()
        }
    }
}
