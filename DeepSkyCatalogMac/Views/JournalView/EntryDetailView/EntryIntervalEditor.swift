//
//  EntryIntervalEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/22/23.
//

import SwiftUI

struct EntryIntervalEditor: View {
    @Environment(\.dismiss) var dismiss
    @Binding var interval: DateInterval?
    @State var intervalProxy: DateInterval
    
    init(interval: Binding<DateInterval?>) {
        self._interval = interval
        self._intervalProxy = State(initialValue: interval.wrappedValue ?? DateInterval())
    }
    
    var body: some View {
        let endBinding = Binding(
            get: {
                return intervalProxy.end
            },
            set: {
                let newDuration = DateInterval(start: intervalProxy.start, end: $0).duration
                intervalProxy.duration = newDuration
            }
        )
        let startBinding = Binding(
            get: {
                return intervalProxy.start
            },
            set: {
                let newDuration = DateInterval(start: $0, end: intervalProxy.end).duration
                intervalProxy.start = $0
                intervalProxy.duration = newDuration
            }
        )
        let startRange: ClosedRange<Date> = Date.distantPast...intervalProxy.end
        let endRange: ClosedRange<Date> = intervalProxy.start...Date.distantFuture
        VStack {
            DatePicker("Start", selection: startBinding, in: startRange)
            DatePicker("End", selection: endBinding, in: endRange)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    self.interval = self.intervalProxy
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button("Remove") {
                    self.interval = nil
                    dismiss()
                }
            }
        }
    }
}
