//
//  LocationManager.swift
//  DeepSkyCatalog
//
//  Created by Ryan Sponzilli on 12/4/22.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var latestLocation: CLLocation? = nil
    @Published var locationEnabled: Bool = false
    
    var locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Delegate function that activates whenever authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationEnabled = false
        case .restricted, .denied:
            locationEnabled = false
        case .authorizedAlways, .authorizedWhenInUse:
            //print("Started Monitoring Significant Location Changes")
            locationManager.startMonitoringSignificantLocationChanges()
            locationEnabled = true
        @unknown default:
            break
        }
    }
    
    // Delegate function that activates whenever it recieves a location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("Did Update Location")
        let newLocation = locations.first
        if newLocation?.coordinate.latitude ?? 0 < 65 && newLocation?.coordinate.latitude ?? 0 > -65 {
            latestLocation = locations.first
        }
    }
    
    // Delegate function that activates whenever an error occurs getting a location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("Did Fail With Error")
        return
    }
    
    // Function that gets a timezone from a location
    static func getTimeZone(location: CLLocation) async -> TimeZone? {
        let geocoder = CLGeocoder()
        if let placemarks = try? await geocoder.reverseGeocodeLocation(location), let tz = placemarks.first?.timeZone {
            return tz
        }
        return nil
    }
}
