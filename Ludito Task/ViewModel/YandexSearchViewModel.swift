//
//  YandexSearchViewModel.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import Foundation
import Combine

class YandexSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var features: [Feature] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let apiKey = "88f8d157-de64-47e4-b415-9061de20233d"

    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.count > 3 {
                    self.fetchOrganizations(query: text)
                } else {
                    self.features = [] // Clear results when input is short
                }
            }
            .store(in: &cancellables)
    }

    func fetchOrganizations(query: String) {
        isLoading = true
        errorMessage = nil

        var components = URLComponents(string: "https://search-maps.yandex.ru/v1/")!
        components.queryItems = [
            URLQueryItem(name: "text", value: query),
            URLQueryItem(name: "type", value: "biz"),
            URLQueryItem(name: "lang", value: "ru_RU"),
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "ll", value: "69.24050945460057,41.309312377631656"),
            URLQueryItem(name: "spn", value: "0.552069,0.400552"),
            URLQueryItem(name: "results", value: "5")
        ]

        guard let url = components.url else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received."
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(FeatureCollection.self, from: data)
                    self.features = decoded.features
                } catch {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
