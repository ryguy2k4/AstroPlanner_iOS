//
//  SwiftUIView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/25/22.
//

import SwiftUI

struct DateIntervalSelector: View {
    @Environment(\.date) var date
    @Binding var viewingInterval: DateInterval
    @State var customViewingInterval: Bool
    let sun: SunData?
    
    var body: some View {
        let startBinding = Binding(
            get: { return viewingInterval.start },
            set: {
                if let sun = sun {
                    // NON NEGOTIABLE CONDITIONS
                    // if new start is before current end and after sunset
                    if $0 < viewingInterval.end && $0 > sun.ATInterval.start {
                        // allow new value
                        viewingInterval.start = $0
                    }
                    else {
                        // set new value to the 12:00 AM on the end day
                        viewingInterval.start = viewingInterval.end.startOfDay()
                    }
                    // if new end is before sunset and sunset is before current end
                    if $0 < sun.ATInterval.start && sun.ATInterval.start < viewingInterval.end {
                        // set new value to sunset
                        viewingInterval.start = sun.ATInterval.start
                    }
                }
            }
        )
        let endBinding = Binding(
            get: { return viewingInterval.end },
            set: {
                if let sun = sun {
                    // NON NEGOTIABLE CONDITIONS
                    // if new end is after current start and before sunrise
                    if $0 > viewingInterval.start && $0 < sun.ATInterval.end {
                        // allow new value
                        viewingInterval.end = $0
                    }
                    // if the end of the start day is before sunrise
                    else if viewingInterval.start.endOfDay() < sun.ATInterval.end {
                        // set new value to the 11:59 PM on the start day
                        viewingInterval.end = viewingInterval.start.endOfDay()
                    }
                    // if new end is after sunrise and sunrise is after current start
                    if $0 > sun.ATInterval.end && sun.ATInterval.end > viewingInterval.start {
                        // set new value to sunrise
                        viewingInterval.end = sun.ATInterval.end
                    }
                }
            }
        )
        
        Picker("", selection: $customViewingInterval) {
            Text("Dusk to Dawn").tag(false)
            Text("Custom").tag(true)
        }
        .pickerStyle(.segmented)
        .onChange(of: customViewingInterval) { newValue in
            if !newValue, let sun = sun {
                viewingInterval = sun.ATInterval
            }
        }
        VStack {
            DatePicker("Start", selection: startBinding)
            DatePicker("End", selection: endBinding)
        }
        .disabled(!customViewingInterval)
        
        // This attempts to put the viewing interval back into its boundaries after changing the start and end times
        // DateInterval maintains duration, so moving start forward could push end out of bounds
        .onChange(of: viewingInterval) { newInterval in
            if let sun = sun {
                if newInterval.start < sun.ATInterval.start {
                    viewingInterval.start = sun.ATInterval.start
                }
                if newInterval.end > sun.ATInterval.end && sun.ATInterval.end > viewingInterval.start {
                    viewingInterval.end = sun.ATInterval.end
                }
            }
        }
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
    init(date: Binding<Date>) {
        self._date = State(initialValue: date.wrappedValue)
        self._boundDate = date
    }
    
    var body: some View {
        VStack {
            Button("Today") {
                // doesnt work between 12am and morning
                date = Date().startOfDay()
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
