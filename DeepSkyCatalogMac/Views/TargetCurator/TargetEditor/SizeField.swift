//
//  SizeField.swift
//  TargetCurator
//
//  Created by Ryan Sponzilli on 7/17/23.
//

import SwiftUI

struct SizeField: View {
    @Binding var arcLength: Double
    @Binding var arcWidth: Double
    var body: some View {
        Section {
            HStack {
                Text("Length:")
                TextField("Length:", value: $arcLength, format: .number)
                    .frame(width: 100)
                Text("Width:")
                TextField("Width: ", value: $arcWidth, format: .number)
                    .frame(width: 100)
            }
        } header: {
            Text("Size")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)
        }
    }
}
