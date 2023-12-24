//
//  TypeField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 7/17/23.
//

import SwiftUI

struct TypeField: View {
    @Binding var type: TargetType

    var body: some View {
        Section {
            Picker("", selection: $type) {
                ForEach(TargetType.allCases) { type in
                    Text(type.rawValue)
                }
            }
            .frame(width: 300)
        } header: {
            Text("Type")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}

