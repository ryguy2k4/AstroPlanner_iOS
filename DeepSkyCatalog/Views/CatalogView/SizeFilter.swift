//
//  SizeFilter.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/22/22.
//

import SwiftUI

struct SizeFilter: View {
    @Binding var min: Double
    @Binding var max: Double
    @State var maxEnabled: Bool
    
    init(min: Binding<Double>, max: Binding<Double>) {
        self._min = min
        self._max = max
        self.maxEnabled = !max.wrappedValue.isNaN
    }
    
    var body: some View {
        VStack {
            Form {
                ConfigSection(header: "Minimum Size", footer: "The longest side of the object measured in arcminutes") {
                    HStack {
                        Spacer()
                        NumberPicker(num: $min, placeValues: [.hundreds, .tens, .ones])
                        Spacer()
                    }
                    .frame(height: 150)
                }
                ConfigSection(header: "Maximum Size", headerToggle: $maxEnabled) {
                    HStack {
                        Spacer()
                        NumberPicker(num: $max, placeValues: [.hundreds, .tens, .ones])
                        Spacer()
                    }
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
}

//struct SizeFilter_Previews: PreviewProvider {
//    static var previews: some View {
//        SizeFilter()
//    }
//}
