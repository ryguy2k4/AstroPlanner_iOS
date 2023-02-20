//
//  SwiftUIView.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/25/22.
//

import SwiftUI

struct DateSelector: View {
    @EnvironmentObject var location: SavedLocation
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
