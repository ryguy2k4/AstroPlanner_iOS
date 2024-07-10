//
//  TargeSchedule.swift
//  DeepSkyCatalogiOS
//
//  Created by Ryan Sponzilli on 12/28/23.
//

import SwiftUI
import SwiftData

struct TargetSchedule : View {
    @Query var targetSettings: [TargetSettings]
    @EnvironmentObject var store: HomeViewModel
    let target: DeepSkyTarget
    let showLimitingAlt: Bool
    
    var body: some View {
        let targetInterval = target.getNextInterval(location: store.location, date: store.date, limitingAlt: showLimitingAlt ? targetSettings.first?.limitingAltitude ?? 0 : 0)
        HStack {
            switch targetInterval.interval {
            case .never:
                EventLabel(date: target.getNextInterval(location: store.location, date: store.date).culmination, image: "arrow.right.and.line.vertical.and.arrow.left")
            case .always:
                EventLabel(date: target.getNextInterval(location: store.location, date: store.date).culmination, image: "arrow.right.and.line.vertical.and.arrow.left")
            case .sometimes(let interval):
                EventLabel(date: interval.start, image: "sunrise")
                EventLabel(date: target.getNextInterval(location: store.location, date: store.date).culmination, image: "arrow.right.and.line.vertical.and.arrow.left")
                EventLabel(date: interval.end, image: "sunset")
            }
        }
    }
    
    /**
     A label that displays a target event
     */
    private struct EventLabel: View {
        @EnvironmentObject var store: HomeViewModel
        var date: Date
        var image: String
        var body: some View {
            HStack {
                Image(systemName: image)
                VStack(spacing: 3) {
                    Text(DateFormatter.shortTimeOnly(timezone: store.location.timezone).string(from: date))
                        .minimumScaleFactor(0.8)
                    Text(DateFormatter.shortDateOnly(timezone: store.location.timezone).string(from: date))
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(width: 110, height: 60)
                
        }
    }
}

