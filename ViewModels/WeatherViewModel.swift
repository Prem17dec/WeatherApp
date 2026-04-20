//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import Foundation
import Combine
import CoreLocation
import UIKit

class WeatherViewModel: ObservableObject {
    @Published var cityName: String = ""
    @Published var currentTemp: String = "--"
    @Published var hourlyForecast: [ForecastItem] = []
    @Published var dailyForecast: [ForecastItem] = []
    @Published var selectedDateIdentifier: String = ""
    
    @Published var isLoading = false
    @Published var isAppInitializing = true
    @Published var locationDenied = false
    
    @Published var searchService = LocationSearchService()
    @Published var activeError: IdentifiableError?
    
    @Published var selectedUnit: TemperatureUnit = .celsius {
        didSet { refreshWeather() }
    }
    
    private var allForecastData: [ForecastItem] = []
    private let weatherService: WeatherServiceProtocol
    private let locationService: LocationServiceProtocol
    private let persistence: PersistenceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var hasLoadedInitialData = false
    
    init(weatherService: WeatherServiceProtocol,
         locationService: LocationServiceProtocol,
         persistence: PersistenceProtocol) {
        self.weatherService = weatherService
        self.locationService = locationService
        self.persistence = persistence
        
        // Initial locale check
        let region = Locale.current.region?.identifier ?? "US"
        self.selectedUnit = (region == "US") ? .fahrenheit : .celsius
    }
    
    func onAppear() {
        guard !hasLoadedInitialData else { return }
        setupBindings()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadInitialData()
        }
    }
    
    private func setupBindings() {
        // Location Updates
        locationService.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.handleLocationFailure()
                }
            }, receiveValue: { [weak self] location in
                self?.determineRegionAndFetchWeather(for: location)
            })
            .store(in: &cancellables)
        
        // Auth Status
        locationService.authorizationStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.updateLocationStatus(status)
            }
            .store(in: &cancellables)
        
        // Settings App Return
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.locationService.requestLocation()
            }
            .store(in: &cancellables)
    }
    
    private func updateLocationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationDenied = false
            // If we were stuck on a denied screen, try to load now
            if !hasLoadedInitialData { loadInitialData() }
        case .denied, .restricted:
            self.locationDenied = true
            self.isAppInitializing = false
            self.isLoading = false
        case .notDetermined:
            self.locationDenied = false
        @unknown default:
            break
        }
    }
    
    private func loadInitialData() {
        if let lastCity = persistence.getLastCity() {
            fetchWeather(city: lastCity)
        } else {
            // No history? Only try location if not already denied
            let status = CLLocationManager().authorizationStatus
            if status == .denied || status == .restricted {
                handleLocationFailure()
            } else {
                locationService.requestLocation()
            }
        }
    }
    
    private func determineRegionAndFetchWeather(for location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self = self else { return }
            if let code = placemarks?.first?.isoCountryCode {
                if code == "US" { self.selectedUnit = .fahrenheit }
                else if code == "IN" { self.selectedUnit = .celsius }
            }
            self.fetchWeatherByLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
    }
    
    func fetchWeather(city: String) {
        guard !city.isEmpty && city != "Search for a city" else { return }
        isLoading = true
        
        weatherService.fetchWeather(city: city, units: selectedUnit.rawValue)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                self?.isAppInitializing = false
                if case .failure = completion {
                    self?.activeError = IdentifiableError(message: "City not found")
                }
            }, receiveValue: { [weak self] response in
                self?.hasLoadedInitialData = true
                self?.allForecastData = response.list
                self?.updateUI(with: response)
                self?.persistence.saveLastCity(response.city.name)
            })
            .store(in: &cancellables)
    }
    
    private func fetchWeatherByLocation(lat: Double, lon: Double) {
        isLoading = true
        weatherService.fetchWeatherByCoordinates(lat: lat, lon: lon, units: selectedUnit.rawValue)
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
                self?.isAppInitializing = false
            }, receiveValue: { [weak self] response in
                self?.hasLoadedInitialData = true
                self?.allForecastData = response.list
                self?.updateUI(with: response)
                self?.persistence.saveLastCity(response.city.name)
            })
            .store(in: &cancellables)
    }
    
    func selectSuggestion(_ suggestion: String) {
        let cityOnly = suggestion.components(separatedBy: ",").first ?? suggestion
        searchService.suggestions = []
        searchService.searchText = ""
        fetchWeather(city: cityOnly)
    }
    
    private func updateUI(with response: ForecastResponse) {
        self.cityName = response.city.name
        if let current = response.list.first {
            self.currentTemp = "\(Int(current.main.temp))°"
            self.selectedDateIdentifier = current.dateIdentifier
            self.hourlyForecast = Array(response.list.prefix(8))
        }
        var uniqueDays: [ForecastItem] = []
        for i in stride(from: 0, to: response.list.count, by: 8) {
            uniqueDays.append(response.list[i])
        }
        self.dailyForecast = uniqueDays
    }
    
    func selectDay(_ item: ForecastItem) {
        self.selectedDateIdentifier = item.dateIdentifier
        if let index = allForecastData.firstIndex(where: { $0.dateIdentifier == item.dateIdentifier }) {
            let endIndex = min(index + 8, allForecastData.count)
            self.hourlyForecast = Array(allForecastData[index..<endIndex])
        }
    }
    
    func refreshWeather() {
        if !cityName.isEmpty && cityName != "Search for a city" {
            fetchWeather(city: cityName)
        }
    }
    
    private func handleLocationFailure() {
        self.locationDenied = true
        self.isAppInitializing = false
        if persistence.getLastCity() == nil {
            self.cityName = "Search for a city"
        }
    }
}
