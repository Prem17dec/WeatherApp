//
//  WeatherCoordinator.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import UIKit
import SwiftUI

class WeatherCoordinator {
    var navigationController: UINavigationController
    
    // Properties to hold dependencies injected from SceneDelegate
    private let weatherService: WeatherServiceProtocol
    private let locationService: LocationServiceProtocol
    private let persistence: PersistenceProtocol
    
    // Update init to match the SceneDelegate call
    init(navigationController: UINavigationController,
         weatherService: WeatherServiceProtocol,
         locationService: LocationServiceProtocol,
         persistence: PersistenceProtocol) {
        self.navigationController = navigationController
        self.weatherService = weatherService
        self.locationService = locationService
        self.persistence = persistence
    }
    
    func start() {
        let vm = WeatherViewModel(
            weatherService: weatherService,
            locationService: locationService,
            persistence: persistence
        )
        let view = WeatherView(viewModel: vm)
        
        // We wrap the SwiftUI View in a Hosting Controller
        let hostingController = UIHostingController(rootView: view)
        
        // We MUST push it to the navigation controller
        navigationController.setViewControllers([hostingController], animated: false)
    }
}
