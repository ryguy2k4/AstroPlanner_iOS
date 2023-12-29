//
//  PlaceValue.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/17/22.
//

import Foundation

enum PlaceValue: Int, CaseIterable {
    case thousandths = -3
    case hundredths = -2
    case tenths = -1
    case ones = 0
    case tens = 1
    case hundreds = 2
    case thousands = 3
    case tenThousands = 4
}
