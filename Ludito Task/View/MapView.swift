//
//  MapView.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

struct MapView: View {
    @ObservedObject var mapModel: MapModel = .shared
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var view: AppView
    @State var mapAction: HomeYandexMapViewAction?
    @State var openSearchSheet = false
    @State var openAddressSheet = false
    @State var alertShow = false
    var body: some View {
        ZStack {
            YandexMapView(action: $mapAction)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if !openSearchSheet {
                    Button(action: {
                        openSearchSheet.toggle()
                    }, label: {
                        HStack(spacing: 9) {
                            Image("magnify")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .padding(.leading, 12)
                            
                            Text(mapModel.addressMap != "" ? mapModel.addressMap : "Поиск")
                                .foregroundStyle(Color(.black))
                                .font(.system(size: 16, weight: .bold))
                                .frame(height: 20)
                                .padding(.vertical)
                            
                            Spacer()
                        }
                        .background(colors.gray4)
                        .frame(height: 48)
                        .cornerRadius(10)
                        .padding(8)
                        .background(.white)
                        .frame(height: 64)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(colors.white2, lineWidth: 1)
                        )
                        .padding(16)
                    })
                }
   
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
                .modifier(BottomViewModifier())
        })
        .sheet(isPresented: $openAddressSheet, content: {
            AddressSheet(closeSheet: $openAddressSheet, openAlert: $alertShow)
                .modifier(BottomViewModifier())
        })
        .alert("Добавить адрес в избранное", isPresented: $alertShow) {
            TextField("", text: $mapModel.addressMap)
            Button("Подтвердить", action: { addItem() })
            Button("Отмена",role: .cancel, action: {})
        }
        
        .onChange(of: mapAction) { action in
            switch action {
            case let .cameraPostionChanged(center):
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
            default:
                break
            }
        }
    }
    
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
}
