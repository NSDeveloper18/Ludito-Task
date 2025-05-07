//
//  MapViewModel.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

extension MapView {
    func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = "Location Name"
            newItem.address = mapModel.addressMap
            newItem.latitude = mapModel.latitude
            newItem.longitude = mapModel.longitude

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func centerToUserLocation() {
        DispatchQueue.main.async {
            mapAction = .showCurrentLocation
            checkLocation(current: YandexMapLocation(latitude: mapModel.latitude, longitude: mapModel.longitude))
        }
    }
    
    func onCameraChanged(_ center: YandexMapLocation) {
        if !openAddressSheet {
            DispatchQueue.main.async {
                checkLocation(current: center)
            }
        }
        
        if mapModel.addressMap != "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                openAddressSheet = true
            }
        }
    }
}
