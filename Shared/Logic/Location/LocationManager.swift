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
}
