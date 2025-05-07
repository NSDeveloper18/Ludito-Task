//
//  MapView.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

struct MapView: View {
    @ObservedObject var mapModel: MapModel = .shared
    @Binding var view: AppView
    @State var mapAction: HomeYandexMapViewAction?
    @State var openSearchSheet = false
    @State var chooseCity = false
    var body: some View {
        ZStack {
            YandexMapView(action: $mapAction, choosedLocation: $chooseCity)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Button(action: {
                    openSearchSheet.toggle()
                }, label: {
                    HStack(spacing: 9) {
                        Image("magnify")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 12)
                        
                        Text("Поиск")
                            .foregroundStyle(Color(.black))
                            .font(.system(size: 16, weight: .bold))
                            .frame(height: 20)
                            .padding(.vertical)
                        
                        Spacer()
                    }
                    .background(Color(hex: "#E0E0E0"))
                    .frame(height: 48)
                    .cornerRadius(10)
                    .padding(8)
                    .background(.white)
                    .frame(height: 64)
                    .cornerRadius(16)
                    .padding(16)
                })
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            mapAction = .showCurrentLocation
                            checkLocation(current: YandexMapLocation(latitude: mapModel.latitude, longitude: mapModel.longitude))
                        }
                    }, label: {
                        ZStack {
                            Circle()
                                .foregroundStyle(.white)
                                .frame(width: 64, height: 64)
                                
                            Image("location")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .padding()
                        }
                        .frame(width: 64, height: 64)
                    })
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
                }
                
                BottomBar(view: $view)
            }
            .edgesIgnoringSafeArea(.bottom)
            
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
