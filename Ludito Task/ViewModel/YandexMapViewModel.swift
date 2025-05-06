//
//  YandexMapViewModel.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI
import YandexMapsMobile
import CoreLocation

#if targetEnvironment(simulator)
public func isM1Simulator() -> Bool {
    return TARGET_CPU_ARM64 != 0
}
#else
public func isM1Simulator() -> Bool { false }
#endif

enum HomeYandexMapViewAction: Equatable {
    case zoomChange(isOut: Bool), showCurrentLocation, cameraPostionChanged(center: YandexMapLocation), courierLocationChanged(lat: Double, lon: Double)
}

struct YandexMapView: UIViewRepresentable {
//    @Binding var clinics: [LocationSt]
//    @Binding var tapClinicModel: LocationSt?
    
    @Binding var action: HomeYandexMapViewAction?
    @Binding var choosedLocation: Bool
    @ObservedObject var mapModel: MapModel = .shared
    
    func makeUIView(context: Context) -> YMKMapView {
        guard let mapView = YMKMapView(frame: .zero, vulkanPreferred: isM1Simulator()) else {
            return UIView() as! YMKMapView
        }
        DebugPrint("SOSYandexMapView Loading...")
        let coordinator = context.coordinator
        // Disable rotate gestures
        mapView.mapWindow.map.isRotateGesturesEnabled = false
        mapView.mapWindow.map.addCameraListener(with: coordinator)
        mapView.mapWindow.map.addInputListener(with: coordinator)
        
        
        // Set the bounding box as the visible region
        let cameraPosition = mapView.mapWindow.map.cameraPosition
        mapView.mapWindow.map.move(with: cameraPosition)
        
        mapView.mapWindow.map.move(
            with: YMKCameraPosition.init(target: YMKPoint(latitude: mapModel.latitudeMapSOS, longitude: mapModel.longitudeMapSOS), zoom: 17, azimuth: 0, tilt: 0),
            animation: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.0),
            cameraCallback: nil)
        coordinator.mapView = mapView

        makeUserLocationLayer(mapView: mapView, context: context)
        
        let imageView = UIImageView(image:  UIImage(named: "setLocationPinIcon"))
        mapView.addSubview(imageView)
        imageView.tag = 111222111
        imageView.center = mapView.center
        
        return mapView
    }
    
    private func makeUserLocationLayer(mapView: YMKMapView, context: Context) {
        let mapKit = YMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(
            with: mapView.mapWindow
        )
        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = false
        
        userLocationLayer.setObjectListenerWith(context.coordinator)
    }
    
    func updateUIView(_ uiView: YMKMapView, context: Context) {
        let currentPosition = uiView.mapWindow.map.cameraPosition
        guard let centerView = uiView.viewWithTag(111222111) else { return  }
        
        
        if choosedLocation {
            if context.coordinator.sosPin == nil {
                centerView.isHidden = true
                let pin = uiView.mapWindow.map.mapObjects.addPlacemark()
                if let image = UIImage(named: "setLocationPinIcon") {
                    pin.setIconWith(image)
                }
                pin.geometry = uiView.mapWindow.map.cameraPosition.target
                context.coordinator.selectedLocationPin = pin
                
                let sosPin = uiView.mapWindow.map.mapObjects.addPlacemark()
                if let image = UIImage(named: "") {
                    sosPin.setIconWith(image)
                }
                context.coordinator.sosPin = sosPin
            }
        } else {
            if let sosPin = context.coordinator.sosPin {
                centerView.isHidden = false
                uiView.mapWindow.map.mapObjects.remove(with: sosPin)
                context.coordinator.sosPin = nil
                if let pin = context.coordinator.selectedLocationPin {
                    uiView.mapWindow.map.mapObjects.remove(with: pin)
                    context.coordinator.selectedLocationPin = nil
                }
            }
        }
        
        var centerPin = CGPoint(x: uiView.center.x, y: uiView.center.y - (centerView.frame.height / 3.0))
        switch action {
        case let .zoomChange(isOut):
            let zoomLevel = currentPosition.zoom + (isOut ? 1 : -1)
                let newPosition = YMKCameraPosition(target: currentPosition.target, zoom: zoomLevel, azimuth: currentPosition.azimuth, tilt: currentPosition.tilt)
            uiView.mapWindow.map.move(with: newPosition, animation: YMKAnimation(type: .smooth, duration: 0.2))
        case .showCurrentLocation:
            let location = CLLocationManager().location?.coordinate ?? CLLocationCoordinate2DMake(41.3447, 69.2062)
            uiView.mapWindow.map.move(
                with: YMKCameraPosition.init(target: YMKPoint(latitude: location.latitude, longitude: location.longitude), zoom: 17, azimuth: currentPosition.azimuth, tilt: currentPosition.tilt),
                animation: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.3),
                cameraCallback: nil)
        case let .cameraPostionChanged(center):
            let newPosition = YMKCameraPosition(target: center.toYMKPoint(), zoom: currentPosition.zoom, azimuth: currentPosition.azimuth, tilt: currentPosition.tilt)
            uiView.mapWindow.map.move(with: newPosition, animation: YMKAnimation(type: .smooth, duration: 0.3))
            centerPin = centerView.center
        case let .courierLocationChanged(lat, lon):
            context.coordinator.sosPin?.geometry = YMKPoint(latitude: lat, longitude: lon)
            
            guard let selectedPinPoint = context.coordinator.sosPin?.geometry else { return }
            guard let sosPinPoint = context.coordinator.sosPin?.geometry else { return }
            
            let centerLatitude = (selectedPinPoint.latitude + sosPinPoint.latitude) / 2
            let centerLongitude = (selectedPinPoint.longitude + sosPinPoint.longitude) / 2
            let centerPoint = YMKPoint(latitude: centerLatitude, longitude: centerLongitude)
            
            let newPosition = YMKCameraPosition(target: centerPoint, zoom: currentPosition.zoom, azimuth: currentPosition.azimuth, tilt: currentPosition.tilt)
           
            uiView.mapWindow.map.move(with: newPosition, animation: YMKAnimation(type: .smooth, duration: 0.3))
         default:
            break
        }
        action = nil
         
        centerView.center = centerPin
        centerView.bringSubviewToFront(uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, YMKUserLocationObjectListener, YMKMapCameraListener,
                       YMKMapInputListener {
        
        var selectedLocationPin: YMKPlacemarkMapObject?
        var sosPin: YMKPlacemarkMapObject?
        var sosMovingPin: YMKPlacemarkMapObject?
        var parent: YandexMapView
        var mapView: YMKMapView?
        var locationChoosed: Bool = false
        var timer: Timer?
        @ObservedObject var mapModel: MapModel = .shared
        init(_ parent: YandexMapView) {
            self.parent = parent
        }
        
        func startUpdatingSOSLocation() {
            timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                let lat = mapModel.latitudeCourierSOS
                let lon = mapModel.longitudeCourierSOS
                
                let newPoint = YMKPoint(latitude: lat, longitude: lon)
                
                // Remove the previous placemark before adding a new one
                if let existingPin = self.sosMovingPin {
                    self.mapView?.mapWindow.map.mapObjects.remove(with: existingPin)
                }

                // Create a new placemark
                let pin = self.mapView?.mapWindow.map.mapObjects.addPlacemark()
                

                pin?.geometry = newPoint
                self.sosMovingPin = pin // Save reference to the new pin
            }
        }

        
        func stopUpdatingSOSLocation() {
            timer?.invalidate()
            timer = nil
        }
        
        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
        
        func onObjectAdded(with view: YMKUserLocationView) {
            let pinPlacemark = view.pin
            //            currentLocationPin?.geometry = view.pin.geometry
            //            currentLocationPin?.geometry = view.arrow.geometry
            pinPlacemark.setIconWith(UIImage(named: "currentLocation") ?? UIImage())
            view.arrow.setIconWith(UIImage(named: "currentLocation") ?? UIImage())
            
            // Set z-index for user location view to be lower
            pinPlacemark.zIndex = 0
            startUpdatingSOSLocation()
        }
        
        func onObjectRemoved(with _: YMKUserLocationView) {
            stopUpdatingSOSLocation() // Stop updating when removed
        }
        
        func onObjectUpdated(
            with view: YMKUserLocationView,
            event _: YMKObjectEvent
        ) {
            //            currentLocationPin?.geometry = view.arrow.geometry
        }
        
        public func onMapTap(with map: YMKMap, point: YMKPoint) {
            let ymPoint = YandexMapLocation.fromYMKPoint(point)
            parent.action = .cameraPostionChanged(center: ymPoint)
        }
        
        func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateReason: YMKCameraUpdateReason, finished: Bool) {
            guard cameraUpdateReason != .application else {
                return
            }
            if finished {
//                limitMapToRegion(map: map)
            }
            // Set view's camera position to current if they are different.
            //            let currentCameraPosition = YandexMapLocation.fromYMKPoint(cameraPosition.target)
            //            parent.action = .cameraPostionChanged(center: currentCameraPosition)
            //            parent.cameraCenterPosition = currentCameraPosition
            
        }
        
        // Keep a reference to the polygon overlay so it can be removed when needed
        var polygonOverlay: YMKPolygonMapObject?
        
        // Helper function to create a polygon overlay with blue color and 0.1 opacity
        func createPolygonOverlay(mapObjects: YMKMapObjectCollection, points: [YMKPoint]) {
            // Remove the existing polygon if it exists
            if let existingOverlay = polygonOverlay {
                mapObjects.remove(with: existingOverlay)
            }
            
            let outerRing = YMKLinearRing(points: points)
            let polygon = YMKPolygon(outerRing: outerRing, innerRings: [])
            let newPolygonOverlay = mapObjects.addPolygon(with: polygon)
            newPolygonOverlay.fillColor =  UIColor(named: "ColorsGreen")?.withAlphaComponent(0.1) ?? UIColor.green.withAlphaComponent(0.1)
            newPolygonOverlay.strokeColor = UIColor(named: "ColorsGreen") ?? UIColor.green
            newPolygonOverlay.strokeWidth = 2.0
            
            // Store the new polygon overlay reference
            polygonOverlay = newPolygonOverlay
        }
        
        // Helper function to check if a point is inside a polygon
        func isPointInsidePolygon(point: YMKPoint, polygon: [YMKPoint]) -> Bool {
            var isInside = false
            var j = polygon.count - 1
            for i in 0..<polygon.count {
                let xi = polygon[i].latitude
                let yi = polygon[i].longitude
                let xj = polygon[j].latitude
                let yj = polygon[j].longitude

                let intersect = ((yi > point.longitude) != (yj > point.longitude)) &&
                                (point.latitude < (xj - xi) * (point.longitude - yi) / (yj - yi) + xi)
                if intersect {
                    isInside = !isInside
                }
                j = i
            }
            return isInside
        }

        // Helper function to find the closest point on the polygon to the target point
        func closestPointOnPolygon(target: YMKPoint, polygon: [YMKPoint]) -> YMKPoint {
            var closestPoint = polygon[0]
            var minDistance = distanceBetween(point1: target, point2: closestPoint)
            
            for i in 1..<polygon.count {
                let currentPoint = polygon[i]
                let currentDistance = distanceBetween(point1: target, point2: currentPoint)
                if currentDistance < minDistance {
                    closestPoint = currentPoint
                    minDistance = currentDistance
                }
            }
            
            return closestPoint
        }

        // Helper function to calculate the distance between two points
        func distanceBetween(point1: YMKPoint, point2: YMKPoint) -> Double {
            let latitudeDiff = point1.latitude - point2.latitude
            let longitudeDiff = point1.longitude - point2.longitude
            return sqrt(latitudeDiff * latitudeDiff + longitudeDiff * longitudeDiff)
        }

        func onMapLongTap(with map: YMKMap, point: YMKPoint) { }
    }
}

public struct YandexMapLocation {
  public let latitude: Double
  public let longitude: Double

  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}

extension YandexMapLocation: Hashable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    areDoublesEqual(lhs.latitude, rhs.latitude) &&
      areDoublesEqual(lhs.longitude, rhs.longitude)
  }

  private static func areDoublesEqual(_ a: Double, _ b: Double) -> Bool {
    fabs(a - b) < 0.000001
  }
}

internal extension YandexMapLocation {
  func toYMKPoint() -> YMKPoint {
    .init(latitude: latitude, longitude: longitude)
  }

  static func fromYMKPoint(_ point: YMKPoint) -> Self {
    .init(
      latitude: point.latitude,
      longitude: point.longitude
    )
  }
}
