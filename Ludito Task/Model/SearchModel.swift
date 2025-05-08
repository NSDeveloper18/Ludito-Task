//
//  SearchModel.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI
import CoreLocation

struct SuggestionResponse: Decodable {
    let results: [Suggestion]
}

struct Suggestion: Decodable, Identifiable {
    var id: String {
        uri ?? text
    }

    let text: String
    let title: Title
    let subtitle: Subtitle?
    let pos: String?
    let uri: String?
    
    var coordinate: CLLocationCoordinate2D? {
        guard let pos = pos else { return nil }
        let components = pos.split(separator: ",")
        if components.count == 2,
           let lon = Double(components[0]),
           let lat = Double(components[1]) {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    struct Title: Decodable {
        let text: String
    }

    struct Subtitle: Decodable {
        let text: String
    }
}

