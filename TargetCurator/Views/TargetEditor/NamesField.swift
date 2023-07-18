//
//  NamesField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 7/17/23.
//

import SwiftUI

struct NamesField: View {
    @Binding var names: [String]?
    let id: String
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Button {
                    if names != nil {
                        names!.append("")
                    } else {
                        names = [""]
                    }
                } label: {
                    Label("Add Name", systemImage: "plus.circle")
                }
                if names != nil {
                    ForEach(0..<names!.count, id: \.self) { index in
                        HStack {
                            Button {
                                names!.remove(at: index)
                                if names!.isEmpty {
                                    names = nil
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            if let unwrappedNames = Binding($names) {
                                TextField("Name:", text: unwrappedNames[index])
                                    .frame(width: 400)
                            }
                        }
                    }
                }
            }
        } header: {
            Text("Names")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}
