//
//  WeatherResponse.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import Foundation

struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: ForecastCity
}

struct ForecastItem: Codable, Identifiable {
    var id: Double { dt }
    let dt: TimeInterval
    let main: MainData
    let weather: [WeatherInfo]
    
    var timeString: String {
        let date = Date(timeIntervalSince1970: dt)
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: date).lowercased()
    }
    
    var dayString: String {
        let date = Date(timeIntervalSince1970: dt)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var dateIdentifier: String {
        let date = Date(timeIntervalSince1970: dt)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct MainData: Codable {
    let temp: Double
}

struct WeatherInfo: Codable {
    let description: String
    let icon: String
}

struct ForecastCity: Codable {
    let name: String
}
