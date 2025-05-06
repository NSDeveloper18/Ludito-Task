//
//  MapView.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

struct MapView: View {
    @ObservedObject var mapModel: MapModel = .shared
    @State var mapAction: HomeYandexMapViewAction?
    @State var openSearchSheet = false
    @State var chooseCity = false
    var body: some View {
        ZStack {
            YandexMapView(action: $mapAction, choosedLocation: $chooseCity)
            VStack {
                Button(action: {
                    openSearchSheet.toggle()
                }, label: {
                    HStack {
                        Text("Поиск...")
                            .padding()
                        Spacer()
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .padding(16)
                })
                
                Spacer()
            }
            
        }
        .sheet(isPresented: $openSearchSheet, content: {
            SearchSheetView()
        })
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                DispatchQueue.main.async {
                    mapAction = .showCurrentLocation
                    checkLocation(current: YandexMapLocation(latitude: mapModel.latitude, longitude: mapModel.longitude))
                }
            }
        }
        .onChange(of: mapAction) { action in
            switch action {
            case let .cameraPostionChanged(center):
                DispatchQueue.main.async {
                    checkLocation(current: center)
                }
            default:
                break
            }
        }
    }
}

#Preview {
    MapView()
}
