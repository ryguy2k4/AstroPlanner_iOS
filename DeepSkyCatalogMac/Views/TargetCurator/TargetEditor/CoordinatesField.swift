//
//  CoordinatesField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 7/17/23.
//

import SwiftUI

struct CoordinatesField: View {
    @Binding var ra: Double
    @Binding var dec: Double
    let subTargets: [String]
    var body: some View {
        Section {
            HStack {
                Button("Center of Sub-Targets") {
                    ra = {
                        var sum = 0.0
                        for id in subTargets {
                            sum += DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == id})!.ra
                        }
                        return sum / Double(subTargets.count)
                    }()
                    dec = {
                        var sum = 0.0
                        for id in subTargets {
                            sum += DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == id})!.dec
                        }
                        return sum / Double(subTargets.count)
                    }()
                }
                Text("Ra:")
                TextField("Ra:", value: $ra, format: .number)
                    .frame(width: 150)
                Text("Dec:")
                TextField("Dec: ", value: $dec, format: .number)
                    .frame(width: 150)
            }
        } header: {
            Text("Coordinates")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}
