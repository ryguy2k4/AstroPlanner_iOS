//
//  MagnitudeField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 7/17/23.
//

import SwiftUI

struct MagnitudeField: View {
    @Binding var magnitude: Double?
    var body: some View {
        Section {
            HStack {
                Text("Magnitude:")
                TextField("Magnitude:", value: $magnitude, format: .number)
                    .frame(width: 100)
            }
        } header: {
            Text("Magnitude")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}
