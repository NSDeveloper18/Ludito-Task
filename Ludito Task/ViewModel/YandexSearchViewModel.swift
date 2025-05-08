//
//  YandexSearchViewModel.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import Foundation
import Combine
import CoreLocation

class YandexSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var suggestions: [Suggestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.count > 2 {
                    self.fetchSuggestions(query: text)
                } else {
                    self.suggestions = []
                }
            }
            .store(in: &cancellables)
    }

    func fetchSuggestions(query: String) {
        isLoading = true
        errorMessage = nil

        var components = URLComponents(string: "https://suggest-maps.yandex.uz/suggest-geo")!
        components.queryItems = [
            URLQueryItem(name: "outformat", value: "json"),
            URLQueryItem(name: "v", value: "9"),
            URLQueryItem(name: "add_coords", value: "1"),
            URLQueryItem(name: "ll", value: "69.279746,41.310987"),
            URLQueryItem(name: "part", value: query)
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
                    let decoded = try JSONDecoder().decode(SuggestionResponse.self, from: data)
                    self.suggestions = decoded.results
                } catch {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}


