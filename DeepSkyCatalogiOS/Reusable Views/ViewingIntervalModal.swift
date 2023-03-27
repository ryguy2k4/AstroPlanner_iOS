//
//  SwiftUIView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/25/22.
//

import SwiftUI

struct ViewingIntervalModal: View {
    @Environment(\.sunData) var sunData
    @Binding var date: Date
    @Binding var viewingInterval: DateInterval
    var body: some View {
        VStack {
            DateSelector(date: $date)
                .padding()
                .font(.title2)
                .fontWeight(.semibold)
            Form {
                ConfigSection(header: "Viewing Interval") {
                    DateIntervalSelector(viewingInterval: $viewingInterval, customViewingInterval: viewingInterval != sunData.ATInterval)
                        .environment(\.sunData, sunData)
                        .environment(\.date, date)
                }
            }
        }
    }
}

struct DateIntervalSelector: View {
    @Binding var viewingInterval: DateInterval
    @State var customViewingInterval: Bool
    @Environment(\.sunData) var sunData
    @Environment(\.date) var date
    @Environment(\.location) var location
    
    var body: some View {
        // Choose Auto vs Custom Interval
        Picker("", selection: $customViewingInterval) {
            Text("Dusk to Dawn").tag(false)
            Text("Custom").tag(true)
        }
        .pickerStyle(.segmented)
        .onChange(of: customViewingInterval) { newValue in
            if !newValue {
                viewingInterval = sunData.ATInterval
            }
        }
        .onChange(of: sunData.ATInterval) { newValue in
            viewingInterval = newValue
        }
        
        // Custom Interval Selector
        if sunData.ATInterval.start < viewingInterval.end && viewingInterval.start < sunData.ATInterval.end {
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
            let startRange: ClosedRange<Date> = sunData.ATInterval.start...viewingInterval.end
            let endRange: ClosedRange<Date> = viewingInterval.start...sunData.ATInterval.end
            VStack {
                DatePicker("Start", selection: startBinding, in: startRange)
                DatePicker("End", selection: endBinding, in: endRange)
            }
            .disabled(!customViewingInterval)}
    }
}

struct DateSelector: View {
    @Binding var date: Date
    @State var isDatePickerModal: Bool = false
    var body: some View {
        HStack {
            Button {
                date = date.yesterday()
            } label: {
                Image(systemName: "chevron.left")
            }
            Button {
                isDatePickerModal = true
            } label: {
                Text("\(date.formatted(date: .numeric, time: .omitted))")
            }
            Button {
                date = date.tomorrow()
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .sheet(isPresented: $isDatePickerModal) {
            DatePickerModal(date: $date)
                .presentationDetents([.fraction(0.4)])
        }
    }
}

struct DatePickerModal: View {
    @State var date: Date
    // this is necessary so that the date only updates after the modal is closed
    @Binding var boundDate: Date
    @Environment(\.location) var location
    init(date: Binding<Date>) {
        self._date = State(initialValue: date.wrappedValue)
        self._boundDate = date
    }
    
    var body: some View {
        VStack {
            Button("Today") {
                // doesnt work between 12am and morning
                date = .now.startOfLocalDay(timezone: location.timezone)
            }
            .buttonStyle(.borderedProminent)
            
            DatePicker("Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
        }
        .onDisappear() {
            boundDate = date
        }
    }
}

//struct DateSelector_Previews: PreviewProvider {
//    static var previews: some View {
//        DateSelector()
//    }
//}
