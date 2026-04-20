//
//  WeatherMocks.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import Foundation
import Combine
import CoreLocation
@testable import WeatherApp

class MockWeatherService: WeatherServiceProtocol {
    var result: Result<ForecastResponse, Error> = .failure(URLError(.badURL))
    
    func fetchWeather(city: String, units: String) -> AnyPublisher<ForecastResponse, Error> {
        return result.publisher.eraseToAnyPublisher()
    }
    
    func fetchWeatherByCoordinates(lat: Double, lon: Double, units: String) -> AnyPublisher<ForecastResponse, Error> {
        return result.publisher.eraseToAnyPublisher()
    }
}

class MockLocationService: LocationServiceProtocol {
    let locationPublisher = PassthroughSubject<CLLocation, Error>()
    let authorizationStatusPublisher = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
    
    func requestLocation() {
        // Triggered by VM
    }
}

class MockPersistence: PersistenceProtocol {
    var lastCity: String?
    func saveLastCity(_ city: String) { lastCity = city }
    func getLastCity() -> String? { return lastCity }
}
