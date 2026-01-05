
//
//  SavedMoviesViewModel.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 15/07/1447 AH.
//


import Foundation
import Combine

class SavedMoviesViewModel: ObservableObject {

    @Published var savedMovies: [SavedMovieRecord] = []
    @Published var isLoading = false

    func getSavedMovies() {

        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            return
        }

        guard let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/saved_movies") else {
            return
        }

        isLoading = true

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(APItoken.APItoken)" , forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in

            DispatchQueue.main.async {
                self.isLoading = false
            }

            guard let data = data else { return }

            let decoded = try? JSONDecoder().decode(SavedMoviesResponse.self, from: data)

            DispatchQueue.main.async {
                self.savedMovies = decoded?.records.filter {
                    $0.fields.user_id == userId
                } ?? []
            }

        }.resume()
    }
}

