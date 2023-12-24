//
//  DesignationsField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 7/17/23.
//

import SwiftUI

struct DesignationsField: View {
    @Binding var designation: [DeepSkyTarget.Designation]
    let sub: Bool
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Button {
                    designation.append(DeepSkyTarget.Designation(catalog: .ngc, number: 0))
                } label: {
                    Label("Add Designation", systemImage: "plus.circle")
                }
                ForEach(0..<designation.count, id: \.self) { index in
                    HStack {
                        Button {
                            designation.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        
                        Picker("", selection: $designation[index].catalog) {
                            ForEach(TargetCatalog.allCases) { catalog in
                                Text(catalog.rawValue)
                            }
                        }
                            .frame(width: 150)
                        TextField("", value: $designation[index].number, format: .number)
                            .frame(width: 50)
                    }
                }
            }
        } header: {
            Text(sub ? "Sub Designations" : "Designations")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}

