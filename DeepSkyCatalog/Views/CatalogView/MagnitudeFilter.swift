//
//  MagnitudeFilter.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/22/22.
//

import SwiftUI

struct MagnitudeFilter: View {
    @Binding var min: Double
    @Binding var max: Double
    @State var maxEnabled: Bool
    
    init(min: Binding<Double>, max: Binding<Double>) {
        self._min = min
        self._max = max
        self.maxEnabled = !max.wrappedValue.isNaN
    }
    
    var body: some View {
        Form {
            ConfigSection(header: "Brightest Magnitude") {
                NumberPicker(num: $min, placeValues: [.ones, .tenths])
                .frame(height: 150)
            }
            ConfigSection(header: "Dimmest Magnitude", headerToggle: $maxEnabled) {
                NumberPicker(num: $max, placeValues: [.ones, .tenths])
                .frame(height: maxEnabled ? 150 : 70)
                .disabled(!maxEnabled)
            }
        }
        .onChange(of: maxEnabled) { enabled in
            max = enabled ? min : .nan
        }
        .onChange(of: min) { newValue in
            if maxEnabled && max < newValue {
                max = min
            }
        }
        .onChange(of: max) { newValue in
            if newValue < min {
                max = min
            }
        }
    }
}

//struct MagnitudeFilter_Previews: PreviewProvider {
//    static var previews: some View {
//        MagnitudeFilter()
//    }
//}
