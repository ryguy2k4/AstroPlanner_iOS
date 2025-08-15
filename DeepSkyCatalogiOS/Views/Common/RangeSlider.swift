//
//  RangeSlider.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 1/19/25 via ChatGPT.
//

import SwiftUI


// initial interval
// range
// onDateSelected

struct RangeSliderView: View {
    @EnvironmentObject var store: HomeViewModel
    @Environment(\.isEnabled) var enabled
    @Binding var viewingInterval: DateInterval
    @State var range: ClosedRange<Double>
    
    
    private let sliderWidth: CGFloat = 300

    var body: some View {
        VStack {
            // Custom slider
            ZStack {
                // Background track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)

                // Highlighted track
                Rectangle()
                    .fill(enabled ? Color.blue : Color.gray.opacity(0.8))
                    .frame(width: calculateHighlightedWidth(), height: 4)
                    .offset(x: calculateHighlightedOffset())

                // Start thumb
                Circle()
                    .fill(enabled ? Color.blue : Color.gray)
                    .frame(width: 20, height: 20)
                    .offset(x: calculateThumbOffset(for: viewingInterval.start.timeIntervalSince1970))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = calculateValue(for: value.location.x)
                                if newValue < viewingInterval.end.timeIntervalSince1970 {
                                    store.viewingInterval = DateInterval(start: Date(timeIntervalSince1970: newValue), end: viewingInterval.end)
                                }
                            }
                    )

                // End thumb
                Circle()
                    .fill(enabled ? Color.blue : Color.gray)
                    .frame(width: 20, height: 20)
                    .offset(x: calculateThumbOffset(for: viewingInterval.end.timeIntervalSince1970))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = calculateValue(for: value.location.x)
                                if newValue > viewingInterval.start.timeIntervalSince1970 {
                                    store.viewingInterval = DateInterval(start: viewingInterval.start, end: Date(timeIntervalSince1970: newValue))
                                }
                            }
                    )
            }
            .frame(width: sliderWidth, height: 40)
            
            // Display interval dates
            HStack {
                Text(store.viewingInterval.start.formatted(date: .numeric, time: .shortened))
                    .font(.footnote)
                Spacer()
                Text(store.viewingInterval.end.formatted(date: .numeric, time: .shortened))
                    .font(.footnote)
            }
        }
        .padding()
    }

    // Helper: Calculate the value based on the thumb's position
    private func calculateValue(for xPosition: CGFloat) -> Double {
        let normalizedPosition = max(0, min(xPosition + sliderWidth / 2, sliderWidth)) // Adjust for center offset
        let rangeSize = range.upperBound - range.lowerBound
        return range.lowerBound + (normalizedPosition / sliderWidth) * rangeSize
    }

    // Helper: Calculate the offset for a thumb
    private func calculateThumbOffset(for value: Double) -> CGFloat {
        let rangeSize = range.upperBound - range.lowerBound
        let normalizedValue = (value - range.lowerBound) / rangeSize
        return (normalizedValue * sliderWidth) - (sliderWidth / 2)
    }

    // Helper: Calculate the width of the highlighted track
    private func calculateHighlightedWidth() -> CGFloat {
        let rangeSize = range.upperBound - range.lowerBound
        let normalizedRange = (viewingInterval.end.timeIntervalSince1970 - viewingInterval.start.timeIntervalSince1970) / rangeSize
        return CGFloat(normalizedRange) * sliderWidth
    }

    // Helper: Calculate the offset for the highlighted track
    private func calculateHighlightedOffset() -> CGFloat {
        let rangeSize = range.upperBound - range.lowerBound
        let normalizedMidPoint = ((viewingInterval.start.timeIntervalSince1970 + viewingInterval.end.timeIntervalSince1970) / 2 - range.lowerBound) / rangeSize
        return (normalizedMidPoint * sliderWidth) - (sliderWidth / 2)
    }
}
