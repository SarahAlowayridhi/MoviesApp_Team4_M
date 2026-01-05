//
//  MoviesCenterVM.swift
//  MoviesClone
//
//  Created by Ghadeer Fallatah on 15/07/1447 AH.
//

import SwiftUI
import Combine

@MainActor
class MovieCenterVM: ObservableObject {
    
    @Published var movies: [MovieRecord] = []
    @Published var actors: [ActorRecord] = []
    @Published var directors: [DirectorRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchMovies() async {
        isLoading = true
        
        do {
            let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/movies")!
            let data = try await APIRequester.fetch(from: url, method: .get)
            
            // DEBUG: Print the raw JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("RAW JSON RESPONSE:")
                print(jsonString)
            }
            
            let response = try JSONDecoder().decode(MoviesResponse.self, from: data)
            movies = response.records
        } catch {
            print("ERROR: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchActors() async {
        isLoading = true
        
        do {
            let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/actors")!
            let data = try await APIRequester.fetch(from: url, method: .get)
            let response = try JSONDecoder().decode(ActorsResponse.self, from: data)
            actors = response.records
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchDirectors() async {
        isLoading = true
        
        do {
            let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/directors")!
            let data = try await APIRequester.fetch(from: url, method: .get)
            let response = try JSONDecoder().decode(DirectorsResponse.self, from: data)
            directors = response.records
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
