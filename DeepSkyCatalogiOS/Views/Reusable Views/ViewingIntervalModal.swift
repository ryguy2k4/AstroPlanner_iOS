//
//  SwiftUIView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/25/22.
//

import SwiftUI
import SwiftData

struct ViewingIntervalModal: View {
    @EnvironmentObject var store: HomeViewModel
    @Environment(\.modelContext) var context
    @Bindable var reportSettings: ReportSettings
    
    var body: some View {
        VStack {
            DateSelector()
                .environmentObject(store)
                .padding()
                .font(.title2)
                .fontWeight(.semibold)
            Form {
                ConfigSection(header: "Viewing Interval") {
                    DateIntervalSelector(viewingInterval: $store.viewingInterval, customViewingInterval: {
                        let nightInterval: DateInterval = {
                            if reportSettings.darknessThreshold == 2 {
                                return store.sunData.CTInterval
                            } else if reportSettings.darknessThreshold == 1 {
                                return store.sunData.NTInterval
                            } else {
                                return store.sunData.ATInterval
                            }
                        }()
                        return store.viewingInterval != nightInterval
                    }())
                }
                
                // Darkness Threshold
                Section {
                    Picker("Darkness Threshold", selection: $reportSettings.darknessThreshold) {
                        Text("Civil Twilight").tag(2)
                        Text("Nautical Twilight").tag(1)
                        Text("Astronomical Twilight").tag(0)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Darkness Threshold")
                } footer: {
                    Text("The darkness threshold specifies how dark it needs to be in order to start imaging. This is reflected above in the Dusk to Dawn Setting for the Viewing Interval. This setting impacts visibility score. The default value is Civil Twilight.")
                }
            }
        }
    }
}

struct DateIntervalSelector: View {
    @Binding var viewingInterval: DateInterval
    @State var customViewingInterval: Bool
    @EnvironmentObject var store: HomeViewModel
    @Query var reportSettings: [ReportSettings]
    
    var body: some View {
        // Choose Auto vs Custom Interval
        Picker("", selection: $customViewingInterval) {
            Text("Dusk to Dawn").tag(false)
            Text("Custom").tag(true)
        }
        .pickerStyle(.segmented)
        .onChange(of: customViewingInterval) { _, newValue in
            if !newValue {
                if reportSettings.first!.darknessThreshold == 2 {
                    viewingInterval = store.sunData.CTInterval
                } else if reportSettings.first!.darknessThreshold == 1 {
                    viewingInterval = store.sunData.NTInterval
                } else {
                    viewingInterval = store.sunData.ATInterval
                }
            }
        }
        
        let nightInterval: DateInterval = {
            if reportSettings.first!.darknessThreshold == 2 {
                return store.sunData.CTInterval
            } else if reportSettings.first!.darknessThreshold == 1 {
                return store.sunData.NTInterval
            } else {
                return store.sunData.ATInterval
            }
        }()
        
        // Custom Interval Selector
        if nightInterval.start <= viewingInterval.end && viewingInterval.start <= nightInterval.end {
            let endBinding = Binding(
                get: {
                    return viewingInterval.end
                },
                set: {
                    let newDuration = DateInterval(start: viewingInterval.start, end: $0).duration
                    viewingInterval.duration = newDuration
                }
            )
            let startBinding = Binding(
                get: {
                    return viewingInterval.start
                },
                set: {
                    let newDuration = DateInterval(start: $0, end: viewingInterval.end).duration
                    viewingInterval.start = $0
                    viewingInterval.duration = newDuration
                }
            )
            let startRange: ClosedRange<Date> = nightInterval.start...viewingInterval.end
            let endRange: ClosedRange<Date> = viewingInterval.start...nightInterval.end
            VStack {
                DatePicker("Start", selection: startBinding, in: startRange)
                DatePicker("End", selection: endBinding, in: endRange)
            }
            .disabled(!customViewingInterval)
        }
    }
}

struct DateSelector: View {
    @EnvironmentObject var store: HomeViewModel
    @State var isDatePickerModal: Bool = false

    var body: some View {
        HStack {
            Button {
                store.date = store.date.yesterday()
            } label: {
                Image(systemName: "chevron.left")
            }
            Button {
                isDatePickerModal = true
            } label: {
                Text("\(store.date.formatted(date: .numeric, time: .omitted))")
            }
            Button {
                store.date = store.date.tomorrow()
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .sheet(isPresented: $isDatePickerModal) {
            DatePickerModal()
                .environmentObject(store)
                .presentationDetents([.fraction(0.5)])
        }
    }
}

struct DatePickerModal: View {
    @State var date: Date?
    @EnvironmentObject var store: HomeViewModel
    @State var didHitTonight: Bool = false
    
    var body: some View {
        VStack {
            if let date = Binding($date) {
                Button("Tonight") {
                    // If its in the morning hours of the next day, still show the info for the previous day (current night)
                    if Sun.sol.getAltitude(location: store.location, time: .now) < -18 && .now > store.sunData.solarMidnight {
                        store.date = .now.startOfLocalDay(timezone: store.location.timezone).yesterday()
                    } else {
                        store.date = .now.startOfLocalDay(timezone: store.location.timezone)
                    }
                    didHitTonight = true
                }
                .buttonStyle(.borderedProminent)
                
                DatePicker("Date", selection: date, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .onDisappear() {
                        if !didHitTonight {
                            store.date = date.wrappedValue
                        }
                    }
            } else {
                ProgressView()
                    .onAppear() {
                        date = store.date
                    }
            }
        }
    }
}
