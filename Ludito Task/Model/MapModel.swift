//
//  MapModel.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 06/05/25.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

class MapModel: ObservableObject {
    static let shared = MapModel()
    @Published var addressMap = ""
    
    @Published var latitude = 41.309312377631656
    @Published var longitude = 69.24050945460057
    
}

private var  localTimer: Timer?
func checkLocation(current: YandexMapLocation) {
    @ObservedObject var mapModel: MapModel = .shared
    localTimer?.invalidate()
    localTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: { _ in
        getAddressFromYandex(latitude: current.latitude, longitude: current.longitude) { address in
            if let address = address {
                DebugPrint("Full Address: \(address)")
            } else {
                searchLocation(lat: current.latitude, lon: current.longitude) { appleAddress in
                    DebugPrint("Full Address: \(appleAddress ?? "N/A")")
                }
            }
        }
    })
}

private func searchLocation(lat: Double, lon: Double, completion: @escaping (String?) -> Void)  {
    @ObservedObject var mapModel: MapModel = .shared
    let geoCoder = CLGeocoder()
    let location = CLLocation(latitude: lat, longitude: lon)
    let currentLocale: Locale? = nil//need current locale
    
    geoCoder.reverseGeocodeLocation(location, preferredLocale: currentLocale) { placemarks, error in
        if let placemarks = placemarks, let placemark = placemarks.first {
            let fullAddress = """
                \(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? ""), \(placemark.country ?? "")
                """
            DebugPrint("Full Address: \(fullAddress)")
            DispatchQueue.main.async {
                mapModel.addressMap = cleanAddress(fullAddress)
            }
        } else {
            DebugPrint("No placemarks found")
        }
    }
}

private func getAddressFromYandex(latitude: Double, longitude: Double, apiKey: String = "4ddc9ec9-3392-4af7-8fe3-1aae599dbb36", completion: @escaping (String?) -> Void)  {
    @ObservedObject var mapModel: MapModel = .shared
    let urlString = "https://geocode-maps.yandex.ru/1.x/?apikey=\(apiKey)&geocode=\(longitude),\(latitude)&format=json&lang=ru"
    
    mapModel.latitude = latitude
    mapModel.longitude = longitude
    
    guard let url = URL(string: urlString) else {
        DebugPrint("Invalid URL")
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            DebugPrint("Error fetching data: \(error)")
            completion(nil)
            return
        }
        
        guard let data = data else {
            DebugPrint("No data received")
            completion(nil)
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let response = json["response"] as? [String: Any],
               let geoObjectCollection = response["GeoObjectCollection"] as? [String: Any],
               let featureMember = geoObjectCollection["featureMember"] as? [[String: Any]],
               let firstGeoObject = featureMember.first?["GeoObject"] as? [String: Any],
               let metaDataProperty = firstGeoObject["metaDataProperty"] as? [String: Any],
               let geocoderMetaData = metaDataProperty["GeocoderMetaData"] as? [String: Any],
               let address = geocoderMetaData["text"] as? String {
                completion(address)
                DispatchQueue.main.async {
                    mapModel.addressMap = cleanAddress(address)
                }
            } else {
                DebugPrint("Invalid JSON structure")
                completion(nil)
            }
        } catch {
            DebugPrint("Error parsing JSON: \(error)")
            completion(nil)
        }
    }
    
    task.resume()
}

func cleanAddress(_ fullAddress: String) -> String {
    // Define the substrings you want to remove
    let substringsToRemove = ["Uzbekistan", "Tashkent", "Узбекистан", "Ташкент", "Oʻzbekiston", "Toshkent", ","]
    
    // Start with the full address
    var cleanedAddress = fullAddress
    
    // Iterate over each substring and replace it with an empty string
    for substring in substringsToRemove {
        cleanedAddress = cleanedAddress.replacingOccurrences(of: substring, with: "")
    }
    
    // Trim any extra whitespace that might be left
    cleanedAddress = cleanedAddress.trimmingCharacters(in: .whitespacesAndNewlines)
    
    return cleanedAddress
}
