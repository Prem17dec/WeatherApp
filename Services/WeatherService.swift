//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import Foundation
import Combine

class WeatherService: WeatherServiceProtocol {
    // Computed property to fetch and clean the key
    private var apiKey: String {
        let rawKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
        // This ensures any quotes or accidental spaces are removed
        return rawKey.trimmingCharacters(in: CharacterSet(charactersIn: "\" "))
    }
    
    private let baseURL = "https://api.openweathermap.org/data/2.5/forecast"
    
    func fetchWeather(city: String, units: String) -> AnyPublisher<ForecastResponse, Error> {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: units)
        ]
        
        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ForecastResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchWeatherByCoordinates(lat: Double, lon: Double, units: String) -> AnyPublisher<ForecastResponse, Error> {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: units)
        ]
        
        return URLSession.shared.dataTaskPublisher(for: components.url!)
            .map(\.data)
            .decode(type: ForecastResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
