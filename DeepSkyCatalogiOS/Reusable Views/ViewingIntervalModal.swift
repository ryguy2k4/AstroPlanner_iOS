//
//  SwiftUIView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/25/22.
//

import SwiftUI

struct ViewingIntervalModal: View {
    @EnvironmentObject var store: HomeViewModel
    var body: some View {
        VStack {
            DateSelector()
                .environmentObject(store)
                .padding()
                .font(.title2)
                .fontWeight(.semibold)
            Form {
                ConfigSection(header: "Viewing Interval") {
                    DateIntervalSelector(viewingInterval: $store.viewingInterval, customViewingInterval: store.viewingInterval != store.sunData.ATInterval)
                }
            }
        }
    }
}

struct DateIntervalSelector: View {
    @Binding var viewingInterval: DateInterval
    @State var customViewingInterval: Bool
    @EnvironmentObject var store: HomeViewModel
    
    var body: some View {
        // Choose Auto vs Custom Interval
        Picker("", selection: $customViewingInterval) {
            Text("Dusk to Dawn").tag(false)
            Text("Custom").tag(true)
        }
        .pickerStyle(.segmented)
        .onChange(of: customViewingInterval) { newValue in
            if !newValue {
                viewingInterval = store.sunData.ATInterval
            }
        }
        .onChange(of: store.sunData.ATInterval) { newValue in
            viewingInterval = newValue
        }
        
        // Custom Interval Selector
        if store.sunData.ATInterval.start <= viewingInterval.end && viewingInterval.start <= store.sunData.ATInterval.end {
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
            let startRange: ClosedRange<Date> = store.sunData.ATInterval.start...viewingInterval.end
            let endRange: ClosedRange<Date> = viewingInterval.start...store.sunData.ATInterval.end
            VStack {
                DatePicker("Start", selection: startBinding, in: startRange)
                DatePicker("End", selection: endBinding, in: endRange)
            }
            .disabled(!customViewingInterval)}
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
    
    var body: some View {
        VStack {
            if let date = Binding($date) {
                Button("Tonight") {
                    // doesnt work between 12am and morning
                    store.date = .now.startOfLocalDay(timezone: store.location.timezone)
                }
                .buttonStyle(.borderedProminent)
                
                DatePicker("Date", selection: date, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .onDisappear() {
                        store.date = date.wrappedValue
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

//struct DateSelector_Previews: PreviewProvider {
//    static var previews: some View {
//        DateSelector()
//    }
//}
