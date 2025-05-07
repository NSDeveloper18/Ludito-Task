//
//  SearchSheetView.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

struct SearchSheetView: View {
    @StateObject private var viewModel = YandexSearchViewModel()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Поиск...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if viewModel.isLoading {
                    ProgressView("Поиск...")
                        .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                List(viewModel.features) { feature in
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
            }
            .navigationTitle("Yandex поиск")
        }
        
    }
}
