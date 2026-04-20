//
//  LocationService.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    let locationPublisher = PassthroughSubject<CLLocation, Error>()
    let authorizationStatusPublisher = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        authorizationStatusPublisher.send(manager.authorizationStatus)
    }
    
    func requestLocation() {
        let status = manager.authorizationStatus
        authorizationStatusPublisher.send(status)
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            locationPublisher.send(completion: .failure(NSError(domain: "LocationDenied", code: 1)))
        @unknown default:
            break
        }
    }
    
    // NEW: Allows the ViewModel to force a check when app foregrounds
    func refreshStatus() {
        authorizationStatusPublisher.send(manager.authorizationStatus)
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationPublisher.send(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationPublisher.send(completion: .failure(error))
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("DEBUG: Authorization status changed to: \(status.rawValue)")
        
        authorizationStatusPublisher.send(status)
        
        // If they just granted permission, grab the location immediately
        if status == .denied || status == .restricted {
            manager.stopUpdatingLocation() // Stop the hardware immediately
        } else if status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
}

