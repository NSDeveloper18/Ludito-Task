//
//  SearchSheetView.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

struct SearchSheetView: View {
    @StateObject private var viewModel = YandexSearchViewModel()
    @FocusState var isKeyboardFocused: Bool
    var body: some View {
            VStack {
                HStack(spacing: 9) {
                    Image("magnify")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.leading, 12)
                    
                    TextField("Поиск...", text: $viewModel.searchText)
                        .focused($isKeyboardFocused)
                        .foregroundStyle(Color(.black))
                        .font(.system(size: 16, weight: .bold))
                        .frame(height: 20)
                        .padding(.vertical)
                    
                    Spacer()
                    
                    if viewModel.searchText != "" {
                        Button(action: {
                            viewModel.searchText = ""
                        }, label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundStyle(Color(.gray))
                                .font(.system(size: 16))
                        })
                        .padding(.trailing, 16)
                    }
                }
                .background(Color(hex: "#E0E0E0"))
                .frame(height: 48)
                .cornerRadius(10)
                .padding(8)
                .background(.white)
                .frame(height: 64)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#F1F1F1"), lineWidth: 1)
                )
                .padding(16)
                
                

                if viewModel.isLoading {
                    ProgressView("Поиск...")
                        .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                ForEach(viewModel.features) { feature in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.properties.companyMetaData.name)
                            .font(.headline)
                        Text(feature.properties.companyMetaData.address)
                            .font(.subheadline)
                        Text("Lat: \(feature.geometry.location.latitude), Lon: \(feature.geometry.location.longitude)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
                
                Spacer()
            }
            .background(Color(hex: "#F1F1F1"))
            .onTapGesture {
                hideKeyboard()
            }
            .onAppear() {
                isKeyboardFocused = true
            }
    }
}
