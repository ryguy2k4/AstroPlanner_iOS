//
//  MinMaxPicker.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/22/22.
//

import SwiftUI
import DeepSkyCore

struct MinMaxPicker: View {
    @Binding var min: Double?
    @Binding var max: Double?
    let maxTitle: String
    let minTitle: String
    let placeValues: [PlaceValue]
    
    init(min: Binding<Double?>, max: Binding<Double?>, minTitle: String, maxTitle: String, placeValues: [PlaceValue]) {
        self._min = min
        self._max = max
        self.maxTitle = maxTitle
        self.minTitle = minTitle
        self.placeValues = placeValues
    }
    
    var body: some View {
        Form {
            Section {
                OptionalNumberPicker(num: $min, placeValues: placeValues)
                .frame(height: 150)
            } header: {
                Text(minTitle)
            }
            Section {
                OptionalNumberPicker(num: $max, placeValues: placeValues)
                .frame(height: 150)
            } header: {
                Text(maxTitle)
            }
        }
        // if the new min is greater than the maximum, raise the max to the min
        .onChange(of: min ?? 0) { _, newMin in
            if let max = max, max < newMin {
                self.max = min
            }
        }
        // if the new max is smaller than the minimum, revert the max to the min
        .onChange(of: max ?? 0) { _, newMax in
            if let min = min, newMax < min {
                self.max = min
            }
        }
    }
}

//struct SizeFilter_Previews: PreviewProvider {
//    static var previews: some View {
//        SizeFilter()
//    }
//}
