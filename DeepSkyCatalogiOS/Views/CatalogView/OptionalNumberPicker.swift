//
//  OptionalNumberPicker.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 9/19/24.
//

import SwiftUI

/**
 This is a custom Picker that allows a number with to be picked with the specified number of digits. When this view is disabled, each number slot displays a dash.
 - Parameter num: The variable that the number picked is bound to
 - Parameter placeValues: How many place values to display to build the number
 - Parameter ranges: Allows customization of what digits to display in each DigitPicker
 */
struct OptionalNumberPicker: View {
    @Binding var num: Double?
    let placeValues: [PlaceValue]
    let ranges: [PlaceValue : Range<Int>]?
    
    init(num: Binding<Double?>, placeValues: [PlaceValue], ranges: [PlaceValue : Range<Int>]? = nil) {
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
    @Binding var num: Double?
    let placeValue: PlaceValue
    let range: Range<Int>
    
    var body: some View {
        // This binding reads from the given digit of the number and writes back to that same digit
        let digitBinding: Binding<Int?> = Binding(
            get: { self.num?.getDigit(placeValue) },
            set: { newValue in
                if num == nil, let v = newValue {
                    self.num = 0
                    self.num = self.num.setDigit(placeValue, to: v)
                } else if let v = newValue {
                    self.num = self.num.setDigit(placeValue, to: v)
                } else {
                    self.num = nil
                }
                
            }
        )
        Picker("", selection: digitBinding) {
            Text("-").tag(nil as Int?)
            ForEach(range, id: \.hashValue) { num in
                Text("\(num)").tag(num)
            }
        }
        .pickerStyle(.wheel)
        .frame(width: 50)
    }
}

