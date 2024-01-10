//
//  Mac_MinMaxPicker.swift
//  DeepSkyCatalogMac
//
//  Created by Ryan Sponzilli on 1/9/24.
//

import SwiftUI

struct Mac_MinMaxPicker: View {
    var min: Binding<Double>
    var max: Binding<Double>?
    var percent: Bool
    let maxTitle: String
    let minTitle: String
    
    init(min: Binding<Double>, max: Binding<Double>? = nil, minTitle: String = "Minimum", maxTitle: String = "Maximum", percent: Bool = false) {
        self.percent = percent
        self.min = min
        self.minTitle = minTitle
        self.max = max
        self.maxTitle = maxTitle
    }
    
    var body: some View {
        VStack {
            let minBinding = Binding(
                get: { return min.wrappedValue },
                set: { newValue in
                    if let max = max?.wrappedValue, newValue < max {
                        min.wrappedValue = newValue
                    } else if max == nil {
                        min.wrappedValue = newValue
                    }
                }
            )
            if let max = max {
                let maxBinding = Binding(
                    get: { return max.wrappedValue },
                    set: { newValue in
                        if newValue > min.wrappedValue {
                            max.wrappedValue = newValue
                        }
                    }
                )
                Form {
                    if percent {
                        TextField(minTitle, value: minBinding, format: .percent)
                        TextField(maxTitle, value: maxBinding, format: .percent)
                    } else {
                        TextField(minTitle, value: minBinding, format: .number)
                        TextField(maxTitle, value: maxBinding, format: .number)
                    }
                }
                .frame(minWidth: 200)
            } else {
                Form {
                    if percent {
                        TextField(minTitle, value: min, format: .percent)
                    } else {
                        TextField(maxTitle, value: min, format: .number)
                    }
                }
            }
        }
        .padding()
    }
}
