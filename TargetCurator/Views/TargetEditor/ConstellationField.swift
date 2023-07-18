//
//  ConstellationField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 7/17/23.
//

import SwiftUI

struct ConstellationField: View {
    @Binding var constellation: Constellation
    var body: some View {
        Section {
            Picker("", selection: $constellation) {
                ForEach(Constellation.allCases) { type in
                    Text(type.rawValue)
                }
            }
            .frame(width: 300)
        } header: {
            Text("Constellation")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}
