//
//  EntryLocationEditor.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 12/21/23.
//

import SwiftUI

struct EntryLocationEditor: View {
    @Environment(\.dismiss) var dismiss
    @Binding var location: Location?
    var body: some View {
        VStack {
            if let location = Binding($location) {
                TextField("Latitude", value: location.latitude, format: .number)
                TextField("Longitude", value: location.longitude, format: .number)
            } else {
                ProgressView("Wait")
                    .onAppear {
                        self.location = Location.default
                    }
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button("Remove") {
                    self.location = nil
                    dismiss()
                }
            }
        }
    }
}
