//
//  Double.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 11/13/22.
//

import Foundation

extension Double {
    
    /**
     Create a date object from a double representing decimal hours on a given date.
     - Parameter date: The date to attatch the hours to.
     - Precondition: self represents a number of hours.
     - Returns: A Date object on the given date at the specified time.
     */
    public func hoursToDate(on date: Date) -> Date {
        let hour = floor(self)
        let minute = floor((self - hour) * 60)
        let second = floor((((self - hour) * 60) - minute) * 60)
        let today = Calendar.current.dateComponents([.year, .day, .month], from: date)
        var dateComps = DateComponents()
        dateComps.hour = Int(hour)
        dateComps.minute = Int(minute)
        dateComps.second = Int(second)
        dateComps.year = today.year
        dateComps.day = today.day
        dateComps.month = today.month
        dateComps.timeZone = TimeZone(abbreviation: "UTC")
        return Calendar.current.date(from: dateComps)!
    }
    
    /**
     Converts degrees to radians.
     - Returns: The given degree in radians.
     - Precondition: self is a degree value.
     */
    public func toRadian() -> Double {
        return self * Double.pi / 180
    }

    /**
     Converts radians to degrees.
     - Returns: The given radian in degrees.
     - Precondition: self is a radian value.
     */
    public func toDegree() -> Double {
        return self / Double.pi * 180
    }
    
    /**
     A custom modulo function for Doubles. The default truncatingRemainder function can result in negative values, this function cannot.
     - Parameter divisor: The number to mod by.
     - Returns: The double after it is brought within range.
     */
    public func mod(by divisor: Double) -> Double {
        let remainder = self.truncatingRemainder(dividingBy: divisor)
        return (remainder >= 0) ? remainder : (remainder + divisor)
    }
    
    /**
     Formats the Double as a percent value.
     - Parameter sigFigs: The number of significant figures to display the decinal with. Defaults to 2.
     - Returns: A String containing the formatted percent.
     */
    public func percent(sigFigs: Int = 2) -> String {
        return self.formatted(.percent.precision(.significantDigits(0...sigFigs)))
    }
    
    /**
     This function gets a certain digit within a number.
     - Parameter place: The PlaceValue to extract.
     - Returns: The digit at the given PlaceValue.
     */
    func getDigit(_ place: PlaceValue) -> Int {
        if self.isNaN { return 0 }
        var num = Float(self)
        num /= pow(10, Float(place.rawValue))
        return abs(Int(num.truncatingRemainder(dividingBy: 10)))
    }
    
    /**
     This function replaces a certain digit specified using a PlaceValue case with a new digit.
     - Parameter place: The place value to change.
     - Parameter newDigit: The digit to replace the old one with.
     - Precondition: newDigit is an element of [0, 9].
     - Returns: A new Double with the digit successfully replaced.
     */
    func setDigit(_ place: PlaceValue, to newDigit: Int) -> Double {
        if self.isNaN {
            return Double(newDigit) * pow(10, Double(place.rawValue))
        }
        let oldDigit = Double(self.getDigit(place))
        let extraction = self - (oldDigit * pow(10, Double(place.rawValue)))
        return extraction + (Double(newDigit) * pow(10, Double(place.rawValue)))
    }
    
    func formatDMS(directionArgs: [FloatingPointSign : String]? = nil) -> String {
        var string = ""
        let negative = self < 0
        var num = self.magnitude
        string.append("\(Int(num))° ")
        num = num.mod(by: 1) * 60
        string.append("\(Int(num))' ")
        num = num.mod(by: 1) * 60
        string.append("\(Int(num))\" ")
        if let directionArgs = directionArgs, let minus = directionArgs[.minus], let plus = directionArgs[.plus] {
            string.append(negative ? minus : plus)
        }
        
        return string
    }
    
    func formatHMS() -> String {
        var string = ""
        var num = self.magnitude / 15
        string.append("\(Int(num))h ")
        num = num.mod(by: 1) * 60
        string.append("\(Int(num))' ")
        num = num.mod(by: 1) * 60
        string.append("\(Int(num))\" ")
        
        return string
    }
}

extension Optional where Wrapped == Double {
    func getDigit(_ place: PlaceValue) -> Int? {
        if let num = self {
            return num.getDigit(place)
        }
        return nil
    }
    
    func setDigit(_ place: PlaceValue, to newDigit: Int) -> Double? {
        if let num = self {
            return num.setDigit(place, to: newDigit)
        }
        return nil
    }
}
