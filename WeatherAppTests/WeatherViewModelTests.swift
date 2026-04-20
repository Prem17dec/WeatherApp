//
//  WeatherViewModelTests.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import XCTest
import Combine
import CoreLocation
@testable import WeatherApp

final class WeatherViewModelTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var mockWeatherService: MockWeatherService!
    var mockLocationService: MockLocationService!
    var mockPersistence: MockPersistence!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService()
        mockLocationService = MockLocationService()
        mockPersistence = MockPersistence()
        cancellables = []
        
        viewModel = WeatherViewModel(
            weatherService: mockWeatherService,
            locationService: mockLocationService,
            persistence: mockPersistence
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockWeatherService = nil
        mockLocationService = nil
        mockPersistence = nil
        cancellables = nil
        super.tearDown()
    }
    
    // Test Unit Toggle
    func testUnitToggleTriggersRefresh() {
        // Arrange
        viewModel.cityName = "New York"
        let response = createMockResponse(cityName: "New York")
        mockWeatherService.result = .success(response)
        
        let expectation = XCTestExpectation(description: "Refresh should trigger loading state")
        
        // Act: Observe isLoading before changing the unit
        viewModel.$isLoading
            .dropFirst() // Drop initial false
            .sink { isLoading in
                if isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.selectedUnit = .fahrenheit
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
    }
    
    // Handling async race condition
    func testCityNotFoundShowsError() {
        // Arrange
        let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "City not found"])
        mockWeatherService.result = .failure(error)
        
        let expectation = XCTestExpectation(description: "Error alert should trigger")
        
        // Act: Start listening BEFORE triggering the fetch
        viewModel.$activeError
            .dropFirst() // Drop initial nil
            .sink { error in
                if error?.message == "City not found" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchWeather(city: "InvalidCity")
        
        // Assert
        wait(for: [expectation], timeout: 2.0)
    }
    
    // Test persistence saving
    func testPersistenceSavesCityOnSuccess() {
        // Arrange
        let cityName = "London"
        mockWeatherService.result = .success(createMockResponse(cityName: cityName))
        
        // Act
        viewModel.fetchWeather(city: cityName)
        
        // Assert
        XCTAssertEqual(mockPersistence.lastCity, cityName)
    }
    
    // Helper to create fake API data
    private func createMockResponse(cityName: String) -> ForecastResponse {
        let city = ForecastCity(name: cityName)
        let main = MainData(temp: 25.0)
        let weather = WeatherInfo(description: "Clear", icon: "01d")
        let item = ForecastItem(dt: Date().timeIntervalSince1970, main: main, weather: [weather])
        return ForecastResponse(list: [item], city: city)
    }
}
