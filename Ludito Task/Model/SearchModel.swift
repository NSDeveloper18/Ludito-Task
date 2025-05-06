//
//  SearchModel.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import Foundation
import CoreLocation

struct FeatureCollection: Decodable {
    let features: [Feature]
}

struct Feature: Decodable, Identifiable {
    var id: String {
        properties.companyMetaData.id
    }
    let geometry: Geometry
    let properties: Properties
}

struct Geometry: Decodable {
    let coordinates: [Double] // [longitude, latitude]

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
    }
}

struct Properties: Decodable {
    let name: String
    let companyMetaData: CompanyMetaData

    enum CodingKeys: String, CodingKey {
        case name
        case companyMetaData = "CompanyMetaData"
    }
}

struct CompanyMetaData: Decodable {
    let id: String
    let name: String
    let address: String
}
