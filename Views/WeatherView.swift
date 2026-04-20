//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color(red: 0.4, green: 0.7, blue: 1.0)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .onTapGesture { isSearchFocused = false }
            
            VStack(spacing: 0) {
                headerView
                
                // Show Denied View only if no city is currently loaded
                if viewModel.locationDenied && (viewModel.cityName == "" || viewModel.cityName == "Search for a city") {
                    Spacer()
                    locationDeniedView
                    Spacer()
                } else {
                    ZStack(alignment: .top) {
                        ScrollView(showsIndicators: false) {
                            mainContentView
                        }
                        .blur(radius: (isSearchFocused && !viewModel.searchService.suggestions.isEmpty) ? 10 : 0)
                        
                        if isSearchFocused && !viewModel.searchService.suggestions.isEmpty {
                            suggestionOverlay
                        }
                    }
                }
            }
            
            if viewModel.isAppInitializing {
                loadingOverlay
            }
        }
        .foregroundColor(.white)
        .onAppear { viewModel.onAppear() }
        .alert(item: $viewModel.activeError) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
            Picker("Unit", selection: $viewModel.selectedUnit) {
                Text("Celsius").tag(TemperatureUnit.celsius)
                Text("Fahrenheit").tag(TemperatureUnit.fahrenheit)
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.white.opacity(0.1)).cornerRadius(8)
            
            HStack {
                TextField("Search city...", text: $viewModel.searchService.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.black)
                    .focused($isSearchFocused)
                
                Button(action: {
                    let query = viewModel.searchService.searchText.trimmingCharacters(in: .whitespaces)
                    if !query.isEmpty {
                        viewModel.fetchWeather(city: query)
                        isSearchFocused = false
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .padding(10).background(Color.white.opacity(0.2)).clipShape(Circle())
                }
            }
        }
        .padding()
    }
    
    private var locationDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash.circle.fill").font(.system(size: 60))
            Text("Location Access Required").font(.title3).bold()
            Text("To show your local weather, please enable location in Settings or search for a city manually above.")
                .font(.subheadline).multilineTextAlignment(.center).padding(.horizontal)
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Settings")
                    .bold().padding().frame(maxWidth: .infinity)
                    .background(Color.white).foregroundColor(.blue).cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .padding().background(Color.black.opacity(0.2)).cornerRadius(20).padding()
    }
    
    private var suggestionOverlay: some View {
        VStack {
            List(viewModel.searchService.suggestions, id: \.self) { suggestion in
                Button(action: {
                    viewModel.selectSuggestion(suggestion)
                    isSearchFocused = false
                }) {
                    Text(suggestion).foregroundColor(.black).frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .listStyle(PlainListStyle()).frame(height: 250).background(Color.white).cornerRadius(12).padding(.horizontal)
            Spacer()
        }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 5) {
                Text(viewModel.cityName).font(.system(size: 35, weight: .medium))
                Text(viewModel.currentTemp).font(.system(size: 90, weight: .thin))
            }
            .padding(.top, 20)
            
            hourlySectionView
            
            VStack(alignment: .leading, spacing: 10) {
                Label("5-DAY FORECAST", systemImage: "calendar").font(.caption).bold().padding(.leading, 5)
                VStack(spacing: 0) {
                    ForEach(viewModel.dailyForecast) { item in
                        Button(action: { viewModel.selectDay(item) }) {
                            HStack {
                                Text(item.dayString).frame(width: 100, alignment: .leading)
                                Spacer()
                                Image(systemName: "cloud.sun.fill")
                                Spacer()
                                Text("\(Int(item.main.temp))°").frame(width: 50, alignment: .trailing).bold()
                            }
                            .padding(.vertical, 14).padding(.horizontal).contentShape(Rectangle())
                            .background(viewModel.selectedDateIdentifier == item.dateIdentifier ? Color.white.opacity(0.2) : Color.clear)
                        }
                        .buttonStyle(PlainButtonStyle())
                        if item.id != viewModel.dailyForecast.last?.id {
                            Divider().background(Color.white.opacity(0.3)).padding(.horizontal)
                        }
                    }
                }
                .background(Color.white.opacity(0.15)).cornerRadius(15)
            }
        }
        .padding()
    }
    
    private var hourlySectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("HOURLY FORECAST", systemImage: "clock").font(.caption).bold().padding(.leading, 5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) {
                    ForEach(viewModel.hourlyForecast) { item in
                        VStack(spacing: 8) {
                            Text(item.timeString).font(.caption)
                            Image(systemName: "cloud.fill")
                            Text("\(Int(item.main.temp))°").bold()
                        }
                    }
                }
                .padding()
            }
            .background(Color.white.opacity(0.15)).cornerRadius(15)
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ProgressView().tint(.white).scaleEffect(1.5)
        }
    }
}
