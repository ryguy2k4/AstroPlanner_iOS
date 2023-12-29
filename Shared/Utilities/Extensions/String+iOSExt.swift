//
//  String.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 2/4/23.
//

import Foundation
import UIKit

// THESE FUNCTIONS REQUIRE UIKIT WHICH DOES NOT WORK ON MAC
extension String {
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
