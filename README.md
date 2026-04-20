# WeatherApp

A clean, modern iOS Weather application built with SwiftUI, Combine, and MVVM architecture.

## Features
- **Real-time Weather:** Fetches 5-day forecasts using the OpenWeatherMap API.
- **Smart Localization:** Automatically toggles between Celsius/Metric (India/Global) and Fahrenheit/Imperial (US) based on GPS location.
- **Address Autocomplete:** Uses MapKit's `MKLocalSearchCompleter` for smooth city searching.
- **Privacy Minded:** Gracefully handles location permission denials and provides a direct link to iOS Settings.
- **Persistence:** Remembers the last searched city for instant loading on app restart.

## Architecture & Tech Stack
- **SwiftUI:** For a declarative, reactive UI.
- **Combine:** Used for data binding between the ViewModel and Services.
- **MVVM + Coordinator:** Separation of concerns and clean navigation logic.
- **XCTest:** Unit tests for the ViewModel logic and API error handling.

## Setup
1. Clone the repository.
2. Open `WeatherApp.xcodeproj`.
3. Add your OpenWeatherMap API Key to `Config.xcconfig`.
4. Build and Run!
