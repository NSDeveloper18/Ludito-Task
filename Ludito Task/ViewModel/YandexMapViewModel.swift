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
    @Binding var action: HomeYandexMapViewAction?
    @Binding var choosedLocation: Bool
    @ObservedObject var mapModel: MapModel = .shared

    func makeUIView(context: Context) -> YMKMapView {
        guard let mapView = YMKMapView(frame: .zero, vulkanPreferred: isM1Simulator()) else {
            return UIView() as! YMKMapView
        }

        let coordinator = context.coordinator
        coordinator.mapView = mapView

        mapView.mapWindow.map.isRotateGesturesEnabled = false
        mapView.mapWindow.map.addCameraListener(with: coordinator)
        mapView.mapWindow.map.addInputListener(with: coordinator)

        // Initial camera position
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(
                target: YMKPoint(latitude: mapModel.latitude, longitude: mapModel.longitude),
                zoom: 17, azimuth: 0, tilt: 0
            ),
            animation: YMKAnimation(type: .smooth, duration: 0.0),
            cameraCallback: nil
        )

        makeUserLocationLayer(mapView: mapView, context: context)

        // Add center pin icon
        let imageView = UIImageView(image: UIImage(named: "setLocationPinIcon"))
        imageView.tag = 111222111
        imageView.contentMode = .scaleAspectFit
        mapView.addSubview(imageView)

        // Position it properly after layout
        DispatchQueue.main.async {
            imageView.center = CGPoint(x: mapView.frame.size.width / 2,
                                       y: mapView.frame.size.height / 2 - imageView.frame.height / 3.0)
        }

        return mapView
    }

    private func makeUserLocationLayer(mapView: YMKMapView, context: Context) {
        let userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = false
        userLocationLayer.setObjectListenerWith(context.coordinator)
    }

    func updateUIView(_ uiView: YMKMapView, context: Context) {
        let currentPosition = uiView.mapWindow.map.cameraPosition
        guard let centerView = uiView.viewWithTag(111222111) else { return }

        // Update pin visibility based on chosen location
        if choosedLocation {
            if context.coordinator.sosPin == nil {
                centerView.isHidden = true

                let pin = uiView.mapWindow.map.mapObjects.addPlacemark()
                if let image = UIImage(named: "setLocationPinIcon") {
                    pin.setIconWith(image)
                }
                pin.geometry = currentPosition.target
                context.coordinator.selectedLocationPin = pin

                let sosPin = uiView.mapWindow.map.mapObjects.addPlacemark()
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

        // Keep the center pin in the middle of screen
        let screenCenter = CGPoint(x: uiView.frame.size.width / 2,
                                   y: uiView.frame.size.height / 2 - centerView.frame.height / 3.0)
        centerView.center = screenCenter
        centerView.bringSubviewToFront(uiView)

        // Handle actions
        switch action {
        case let .zoomChange(isOut):
            let zoomLevel = currentPosition.zoom + (isOut ? 1 : -1)
            let newPosition = YMKCameraPosition(target: currentPosition.target, zoom: zoomLevel, azimuth: currentPosition.azimuth, tilt: currentPosition.tilt)
            uiView.mapWindow.map.move(with: newPosition, animation: YMKAnimation(type: .smooth, duration: 0.2))

        case .showCurrentLocation:
            let location = CLLocationManager().location?.coordinate ?? CLLocationCoordinate2D(latitude: 41.3447, longitude: 69.2062)
            let newPosition = YMKCameraPosition(target: YMKPoint(latitude: location.latitude, longitude: location.longitude), zoom: 17, azimuth: currentPosition.azimuth, tilt: currentPosition.tilt)
            uiView.mapWindow.map.move(with: newPosition, animation: YMKAnimation(type: .smooth, duration: 0.3))

        case let .cameraPostionChanged(center):
            let newPosition = YMKCameraPosition(target: center.toYMKPoint(), zoom: currentPosition.zoom, azimuth: currentPosition.azimuth, tilt: currentPosition.tilt)
            uiView.mapWindow.map.move(with: newPosition, animation: YMKAnimation(type: .smooth, duration: 0.3))

        default: break
        }

        action = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, YMKUserLocationObjectListener, YMKMapCameraListener, YMKMapInputListener {
        func onMapLongTap(with map: YMKMap, point: YMKPoint) {}

        var selectedLocationPin: YMKPlacemarkMapObject?
        var sosPin: YMKPlacemarkMapObject?
        var parent: YandexMapView
        var mapView: YMKMapView?
        @ObservedObject var mapModel: MapModel = .shared

        init(_ parent: YandexMapView) {
            self.parent = parent
        }

        func onObjectAdded(with view: YMKUserLocationView) {
            let pinImage = UIImage(named: "currentLocation") ?? UIImage()
            view.pin.setIconWith(pinImage)
            view.arrow.setIconWith(pinImage)
            view.pin.zIndex = 0
        }

        func onObjectRemoved(with _: YMKUserLocationView) {}
        func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}

        func onMapTap(with map: YMKMap, point: YMKPoint) {
            let ymPoint = YandexMapLocation.fromYMKPoint(point)
            parent.action = .cameraPostionChanged(center: ymPoint)
        }

        func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateReason: YMKCameraUpdateReason, finished: Bool) {
            if cameraUpdateReason == .application { return }

            if finished {
                let currentCameraPosition = YandexMapLocation.fromYMKPoint(cameraPosition.target)
                parent.action = .cameraPostionChanged(center: currentCameraPosition)
            }
        }
    }
}

// Location model + extensions
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
        fabs(lhs.latitude - rhs.latitude) < 0.000001 &&
        fabs(lhs.longitude - rhs.longitude) < 0.000001
    }
}

internal extension YandexMapLocation {
    func toYMKPoint() -> YMKPoint {
        .init(latitude: latitude, longitude: longitude)
    }

    static func fromYMKPoint(_ point: YMKPoint) -> Self {
        .init(latitude: point.latitude, longitude: point.longitude)
    }
}
