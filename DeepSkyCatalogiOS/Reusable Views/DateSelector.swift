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
                    // new start is after sunset and before end
                    if $0 > sun.ATInterval.start {
                        // new start is on the next day
                        print(viewingInterval.start.endOfDay())
                        if $0 > viewingInterval.start.endOfDay() {
                            // set the new value to the start of the next day
                            let newDuration = DateInterval(start: viewingInterval.end.startOfDay(), end: viewingInterval.end).duration
                            viewingInterval.start = viewingInterval.end.startOfDay()
                            viewingInterval.duration = newDuration
                        }
                        // new start is on the current day
                        else {
                            // allow the new value
                            let newDuration = DateInterval(start: $0, end: viewingInterval.end).duration
                            viewingInterval.start = $0
                            viewingInterval.duration = newDuration
                        }
                    }
                    // new start is before sunset
                    else {
                        // set new value to sunset
                        let newDuration = DateInterval(start: sun.ATInterval.start, end: viewingInterval.end).duration
                        viewingInterval.start = sun.ATInterval.start
                        viewingInterval.duration = newDuration
                        
                    }
                }
            }
        )
        let endBinding = Binding(
            get: { return viewingInterval.end },
            set: {
                if let sun = sun {
                    // new end is before sunrise and after start
                    if $0 < sun.ATInterval.end {
                        // new end is on previous day
                        if $0 < viewingInterval.end.startOfDay() {
                            // set new value to the 11:59 PM on the start day
                            let newDuration = DateInterval(start: viewingInterval.start, end: viewingInterval.start.endOfDay()).duration
                            viewingInterval.duration = newDuration
                        }
                        // new end is on same day
                        else {
                            // allow new value
                            let newDuration = DateInterval(start: viewingInterval.start, end: $0).duration
                            viewingInterval.duration = newDuration
                        }
                        
                    }
                    // new end is after sunrise
                    else  {
                        // set new value to sunrise
                        let newDuration = DateInterval(start: viewingInterval.start, end: sun.ATInterval.end).duration
                        viewingInterval.duration = newDuration
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
