//
//  LocationManager.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/4/22.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    @objc dynamic var latestLocation: CLLocation?

    func requestLocation() {
        locationManager.delegate = self
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latestLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location")
    }
    
    static func getTimeZone(location: CLLocation, completion: @escaping ((TimeZone?) -> Void)) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemarks = placemarks, let tz = placemarks.first?.timeZone {
                completion(tz)
            } else {
                completion(nil)
            }
        }
    }
}
