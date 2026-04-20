//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: WeatherCoordinator? // <--- MUST BE HERE (Top Level)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 1. Initialize the Window
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // 2. Initialize the Nav stack
        let nav = UINavigationController()
        window.rootViewController = nav
        
        // 3. Make it visible FIRST
        window.makeKeyAndVisible()
        
        // 4. Start the Coordinator (now it has a visible context to push to)
        self.appCoordinator = WeatherCoordinator(
            navigationController: nav,
            weatherService: WeatherService(),
            locationService: LocationService(),
            persistence: PersistenceService()
        )
        appCoordinator?.start()
        
        print("DEBUG: SceneDelegate finished setup")
    }}
