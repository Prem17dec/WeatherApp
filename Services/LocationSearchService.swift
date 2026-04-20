//
//  LocationSearchService.swift
//  WeatherApp
//
//  Created by Prem Kumar Nallamothu on 4/19/26.
//

import Foundation
import MapKit
import Combine

class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var suggestions: [String] = []
    @Published var searchText: String = "" {
        didSet {
            // This triggers the search whenever the text changes
            completer.queryFragment = searchText
        }
    }
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        // Focus on addresses/cities rather than business names
        completer.resultTypes = .address
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // We map the results to just the titles (City names)
        DispatchQueue.main.async {
            self.suggestions = completer.results.map { $0.title }
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Autocomplete error: \(error.localizedDescription)")
    }
}
