//
//  MinMaxPicker.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/22/22.
//

import SwiftUI

struct MinMaxPicker: View {
    @Binding var min: Double
    @Binding var max: Double
    @State var maxEnabled: Bool
    let maxTitle: String
    let minTitle: String
    let placeValues: [PlaceValue]
    
    init(min: Binding<Double>, max: Binding<Double>, maxTitle: String, minTitle: String, placeValues: [PlaceValue]) {
        self._min = min
        self._max = max
        self.maxEnabled = !max.wrappedValue.isNaN
        self.maxTitle = maxTitle
        self.minTitle = minTitle
        self.placeValues = placeValues
    }
    
    var body: some View {
        Form {
            ConfigSection(header: minTitle) {
                NumberPicker(num: $min, placeValues: placeValues)
                .frame(height: 150)
            }
            ConfigSection(header: maxTitle, headerToggle: $maxEnabled) {
                NumberPicker(num: $max, placeValues: placeValues)
                .frame(height: maxEnabled ? 150 : 70)
                .disabled(!maxEnabled)
            }
        }
        .onChange(of: maxEnabled) { _, newValue in
            max = newValue ? min : .nan
        }
        .onChange(of: min) { _, newValue in
            if maxEnabled && max < newValue {
                max = min
            }
        }
        .onChange(of: max) { _, newValue in
            if newValue < min {
                max = min
            }
        }
    }
}

//struct SizeFilter_Previews: PreviewProvider {
//    static var previews: some View {
//        SizeFilter()
//    }
//}
