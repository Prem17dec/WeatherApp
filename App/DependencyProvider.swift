//
//  DependencyProvider.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import Foundation

/// This acts as a simple container for our services.
class DependencyProvider {
    let weatherService: WeatherServiceProtocol
    let locationService: LocationService
    let persistence: PersistenceProtocol
    
    init() {
        self.weatherService = WeatherService()
        self.locationService = LocationService()
        self.persistence = PersistenceService()
    }
}
