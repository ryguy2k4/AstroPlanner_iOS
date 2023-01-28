//
//  String.swift
//  Deep Sky Catalog
//
//  Created by Ryan Sponzilli on 11/11/22.
//

import Foundation
import SwiftUI

extension String {
    /**
     Converts a String representation of an ISO8601 Date into a Date object.
     - Returns: A Date object.
     */
    public func formatStringToDate(with format: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZ", on date: Date? = nil) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone =  format.contains("yyyy-MM-dd'T'HH:mm:ssZZZZZ") ? TimeZone(abbreviation: "UTC") : .current
        dateFormatter.dateFormat = format
        if let date = date {
            dateFormatter.defaultDate = date
        }
       
        return dateFormatter.date(from: self)!
    }
    
    /**
     Determines the pixel width of a String.
     - Parameter usingFont: The font the String is displayed in.
     - Returns: A CGFloat value of the width.
     */
    func widthOfString(usingFont font: UIFont) -> CGFloat {
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = self.size(withAttributes: fontAttributes)
            return size.width
    }
    
    /**
     Determines the pixel height of a String.
     - Parameter usingFont: The font the String is displayed in.
     - Returns: A CGFloat value of the height.
     */
    func heightOfString(usingFont font: UIFont) -> CGFloat {
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = self.size(withAttributes: fontAttributes)
            return size.height
    }
}
