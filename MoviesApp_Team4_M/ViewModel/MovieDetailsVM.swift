//
//  MovieDetailsVM.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 13/07/1447 AH.
//
import Foundation
import Combine

@MainActor
final class MovieDetailsVM: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var movieFields: MovieFields?
    @Published var recordId: String?

    var titleText: String { movieFields?.name ?? "Loading..." }
    var runtimeText: String { movieFields?.runtime ?? "-" }
    var languageText: String { (movieFields?.language ?? []).joined(separator: ", ") }
    var genreText: String { (movieFields?.genre ?? []).joined(separator: ", ") }
    var storyText: String { movieFields?.story ?? "-" }
    var imdbText: String { String(format: "%.1f", movieFields?.IMDb_rating ?? 0) }

    func load(recordId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false } // ensures it flips off even if there's an error

        do {
            let record = try await Airtable.fetchMovieById(recordId: recordId)
            self.recordId = record.id
            self.movieFields = record.fields
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
