//
//  WeatherProtocols.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import Foundation
import Combine
import CoreLocation

protocol WeatherServiceProtocol {
    func fetchWeather(city: String, units: String) -> AnyPublisher<ForecastResponse, Error>
    func fetchWeatherByCoordinates(lat: Double, lon: Double, units: String) -> AnyPublisher<ForecastResponse, Error>
}

protocol LocationServiceProtocol {
    var locationPublisher: PassthroughSubject<CLLocation, Error> { get }
    var authorizationStatusPublisher: CurrentValueSubject<CLAuthorizationStatus, Never> { get }
    func requestLocation()
}

protocol PersistenceProtocol {
    func saveLastCity(_ city: String)
    func getLastCity() -> String?
}

enum TemperatureUnit: String {
    case celsius = "metric"
    case fahrenheit = "imperial"
}

struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}
