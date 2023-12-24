//
//  SubTargetsField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 7/17/23.
//

import SwiftUI

struct SubTargetsField: View {
    @Binding var subTargets: [String]
    @Binding var subDesignations: [DeepSkyTarget.Designation]
    @State var isPopover = false
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        subTargets.append(.init())
                    } label: {
                        Label("Add Sub Target", systemImage: "plus.circle")
                    }
                    Button {
                        var subs: Set<DeepSkyTarget.Designation> = []
                        for item in subTargets {
                            let target = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == item})!
                            subs.formUnion(target.designation)
                            subs.formUnion(target.subDesignations)
                        }
                        subDesignations = Array(subs)
                    } label: {
                        Label("Merge Sub-Designations", systemImage: "arrow.triangle.merge")
                    }
                }
                ForEach(subTargets.indices, id: \.self) { index in
                    HStack {
                        Button {
                            subTargets.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                        }

                        if let target = DeepSkyTargetList.allTargets.first(where: {$0.id.uuidString == subTargets[index]}) {
                            Text(target.defaultName)
                        } else {
                            Text("No Match")
                                .foregroundColor(.red)
                        }
                        TargetIDSearchField(searchText: $subTargets[index])
                    }
                }
            }
        } header: {
            Text("Sub Targets")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}
