//
//  PersistenceService.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import Foundation

class PersistenceService: PersistenceProtocol {
    private let lastCityKey = "last_searched_city"
    
    func saveLastCity(_ city: String) {
        UserDefaults.standard.set(city, forKey: lastCityKey)
    }
    
    func getLastCity() -> String? {
        return UserDefaults.standard.string(forKey: lastCityKey)
    }
}
