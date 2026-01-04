//
//  MovieCenterVM.swift
//  MoviesApp_Team4_M
//  Created by Ghadeer Fallatah on 03/07/1447 AH.
//
import SwiftUI
import Combine

class MovieCenterVM: ObservableObject {
    
    @Published var movies: Movie?
    @Published var actors: Actors?
    @Published var directors: Directors?
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var movieFields: AirtableMovieFields? = nil

    // MARK: - Display values (View reads these, no logic in View)
    var titleText: String { movieFields?.name ?? "Loading..." }
    var runtimeText: String { movieFields?.runtime ?? "-" }
    var languageText: String { (movieFields?.language ?? []).joined(separator: ", ") }
    var genreText: String { (movieFields?.genre ?? []).joined(separator: ", ") }
    var storyText: String { movieFields?.story ?? "-" }
    var imdbText: String {
        let value = movieFields?.IMDb_rating ?? 0
        return String(format: "%.1f", value)
    }

    func load(recordId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let record = try await Airtable.fetchMovieById(recordId: recordId)
            movieFields = record.fields
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    func fetchMovies() async throws -> Movie {
        let endpoint = "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
        guard let url = URL(string: endpoint) else {
            throw errors.invalidURL
        }
        
        let(data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw errors.invalidResponse
        }
        
        do{
            let decoder = JSONDecoder()
            return try decoder.decode(Movie.self, from: data)
        } catch {
            throw errors.invalidData
        }
    }
    
    enum errors: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
}
