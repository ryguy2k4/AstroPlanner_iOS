//
//  EntryPlanEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/27/23.
//

import SwiftUI

struct EntryPlanEditor: View {
    @Environment(\.dismiss) var dismiss
    @Binding var plan: [JournalEntry.JournalImageSequence]?
    @State var planProxy: [JournalEntry.JournalImageSequence]
    
    init(plan: Binding<[JournalEntry.JournalImageSequence]?>) {
        self._plan = plan
        self._planProxy = State(initialValue: plan.wrappedValue ?? [])
    }
    
    var body: some View {
        VStack {
            Grid {
                // Header Row
                GridRow {
                    Text("")
                    Text("Filter")
                    Text("Exposure")
                    Text("Binning")
                    Text("Gain")
                    Text("Offset")
                    Text("Usable")
                    Text("Captured")
                }
                .fontWeight(.semibold)
                // Sequence Rows
                ForEach($planProxy) { plan in
                    let filterNameBinding = Binding(
                        get: { return plan.wrappedValue.filterName ?? ""},
                        set: { newValue in
                            if let index = self.planProxy.firstIndex(where: {$0 == plan.wrappedValue}) {
                                self.planProxy[index].filterName = newValue
                            }
                        }
                    )
                    GridRow {
                        Button {
                            planProxy.remove(at: self.planProxy.firstIndex(where: {$0 == plan.wrappedValue})!)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        TextField("Filter", text: filterNameBinding)
                        TextField("Exposure", value: plan.exposureTime, format: .number)
                        Text("\(plan.wrappedValue.binning ?? 1)x\(plan.wrappedValue.binning ?? 1)")
                        TextField("Gain", value: plan.gain, format: .number)
                        TextField("Offset", value: plan.offset, format: .number)
                        TextField("Usable", value: plan.numUsable, format: .number)
                        TextField("Captured", value: plan.numCaptured, format: .number)
                    }
                }
            }
            // New Sequence Button
            HStack {
                Spacer()
                Button {
                    planProxy.append(.init())
                } label: {
                    Label("Add Sequence", systemImage: "plus.circle")
                }
            }

        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if planProxy != [] {
                        self.plan = planProxy
                    }
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
                    self.plan = nil
                    dismiss()
                }
            }
        }
    }
}
