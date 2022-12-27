//
//  NumberPicker.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/19/22.
//

import SwiftUI

/**
 This is a custom Picker that allows a number with to be picked with the specified number of digits. When this view is disabled, each number slot displays a dash.
 - Parameter num: The variable that the number picked is bound to
 - Parameter placeValues: How many place values to display to build the number
 - Parameter ranges: Allows customization of what digits to display in each DigitPicker
 */
struct NumberPicker: View {
    @Binding var num: Double
    let placeValues: [PlaceValue]
    let ranges: [PlaceValue : Range<Int>]?
    
    init(num: Binding<Double>, placeValues: [PlaceValue], ranges: [PlaceValue : Range<Int>]? = nil) {
        self._num = num
        self.placeValues = placeValues
        self.ranges = ranges
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            ForEach(placeValues, id: \.rawValue) { place in
                if place == .tenths {
                    Text(".")
                        .fontWeight(.black)
                }
                DigitPicker(num: $num, placeValue: place, range: ranges?[place] ?? 0..<10)
            }
            Spacer()
        }
    }
}

fileprivate struct DigitPicker: View {
    @Environment(\.isEnabled) private var isEnabled
    @Binding var num: Double
    let placeValue: PlaceValue
    let range: Range<Int>
    
    var body: some View {
        // This binding reads from the given digit of the number and writes back to that same digit
        let digitBinding = Binding(
            get: { self.num.getDigit(placeValue) },
            set: { self.num = self.num.setDigit(placeValue, to: $0)}
        )
        Picker("", selection: digitBinding) {
            if isEnabled {
                ForEach(range, id: \.hashValue) { num in
                    Text("\(num)").tag(num)
                }
            } else {
                // Display a "-" when the view is disabled
                Text("-")
            }
        }
        .pickerStyle(.wheel)
        .frame(width: 50)
    }
}
