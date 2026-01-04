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

    // MARK: - View State

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var movieFields: AirtableMovieFields?
    @Published var recordId: String?

    @Published var actors: [Actors] = []
    @Published var director: Directors?
    @Published var reviews: [AirtableRecord<AirtableReviewFields>] = []
    @Published var averageAppRatingText: String = "0.0"

    // Save state
    @Published var isSaving = false
    @Published var saveErrorMessage: String?
    @Published var isSaved = false

    // Share Sheet
    @Published var isShareSheetPresented = false
    @Published var shareItems: [Any] = []

    // MARK: - UI Text Helpers

    var titleText: String { movieFields?.name ?? "Loading..." }
    var runtimeText: String { movieFields?.runtime ?? "-" }
    var languageText: String { (movieFields?.language ?? []).joined(separator: ", ") }
    var genreText: String { (movieFields?.genre ?? []).joined(separator: ", ") }
    var storyText: String { movieFields?.story ?? "-" }
    var imdbText: String { String(format: "%.1f", movieFields?.IMDb_rating ?? 0) }

    var directorNameText: String { director?.name ?? "-" }
    var directorImageURL: URL? { URL(string: director?.image ?? "") }

    var reviewsUI: [ReviewUI] {
        reviews.map { rec in
            let f = rec.fields
            return ReviewUI(
                id: rec.id,
                userName: f.user_id ?? "User",
                stars: Int((f.rate ?? 0).rounded()),
                text: f.review_text ?? "",
                dateText: ""
            )
        }
    }

    // MARK: - Public Actions

    func load(recordId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let record = try await Airtable.fetchMovieById(recordId: recordId)
            self.recordId = record.id
            self.movieFields = record.fields

            await fetchDirector()
            await fetchActors()
            await fetchReviews()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func actorImageURL(_ actor: Actors) -> URL? {
        URL(string: actor.image ?? "")
    }

    func prepareShare(recordId: String) {
        let title = titleText.isEmpty ? "Movie" : titleText
        let deepLink = URL(string: "moviesapp://movie/\(recordId)")!
        let message = "Check out \(title)"

        shareItems = [message, deepLink]
        isShareSheetPresented = true
    }

    func saveMovieToSaved(userId: String, movieRecordId: String) async {
        guard !isSaved else { return }

        isSaving = true
        saveErrorMessage = nil
        defer { isSaving = false }

        do {
            let fields = Airtable.SavedMovieCreateFields(
                user_id: userId,
                movie_id: [movieRecordId]
            )
            try await Airtable.createSavedMovie(fields: fields)

            isSaved = true
            setSavedLocal(userId: userId, movieRecordId: movieRecordId, saved: true)
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Local Saved State (UserDefaults)

    func loadSavedLocalState(userId: String, movieRecordId: String) {
        let key = savedKey(for: userId)
        let savedSet = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        isSaved = savedSet.contains(movieRecordId)
    }

    private func savedKey(for userId: String) -> String {
        "saved_movies_local_\(userId)"
    }

    private func setSavedLocal(userId: String, movieRecordId: String, saved: Bool) {
        let key = savedKey(for: userId)

        var set = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        if saved {
            set.insert(movieRecordId)
        } else {
            set.remove(movieRecordId)
        }

        UserDefaults.standard.set(Array(set), forKey: key)
    }

    // MARK: - Fetching (Airtable)

    private func fetchDirector() async {
        // A) Direct director id inside movieFields
        if let directorId = movieFields?.director?.first {
            do {
                let rec: AirtableRecord<Directors> = try await Airtable.fetchById(
                    table: Airtable.directorsTable,
                    recordId: directorId
                )
                director = rec.fields
                return
            } catch {
                print("fetchDirector (direct) failed:", error)
            }
        }

        // B) Join table fallback: movie_directors
        guard let movieRecordId = self.recordId else {
            director = nil
            return
        }

        let formula = #"movie_id="\#(movieRecordId)""#

        do {
            let links: [AirtableRecord<MovieDirectorLinkFields>] = try await Airtable.listRecords(
                table: Airtable.movieDirectorsTable,
                filterByFormula: formula,
                maxRecords: 10
            )

            guard
                let directorId = links.compactMap({ $0.fields.director_id?.first }).first
            else {
                print("No director_id found in movie_directors for movie:", movieRecordId)
                director = nil
                return
            }

            let rec: AirtableRecord<Directors> = try await Airtable.fetchById(
                table: Airtable.directorsTable,
                recordId: directorId
            )
            director = rec.fields

            print("Director loaded:", director?.name ?? "-")
        } catch {
            print("fetchDirector (join) failed:", error)
            director = nil
        }
    }

    private func fetchActors() async {
        // A) Direct actor ids inside movieFields
        let directActorIds = movieFields?.actors ?? []
        if !directActorIds.isEmpty {
            await fetchActorsByIds(directActorIds)
            return
        }

        // B) Join table fallback: movie_actors
        guard let movieRecordId = self.recordId else {
            actors = []
            return
        }

        let formula = #"movie_id="\#(movieRecordId)""#

        do {
            let links: [AirtableRecord<MovieActorLinkFields>] = try await Airtable.listRecords(
                table: Airtable.movieActorsTable,
                filterByFormula: formula,
                maxRecords: 50
            )

            let actorIds = links.compactMap { $0.fields.actor_id?.first }
            guard !actorIds.isEmpty else {
                print("No actor_id found in movie_actors for movie:", movieRecordId)
                actors = []
                return
            }

            await fetchActorsByIds(actorIds)
            print("Actors loaded:", actors.map { $0.name ?? "-" })
        } catch {
            print("fetchActors (join) failed:", error)
            actors = []
        }
    }

    // Make this method explicitly nonisolated so decoding and networking happen off the main actor.
    nonisolated private func fetchActorsByIds(_ ids: [String]) async {
        var result: [Actors] = []
        result.reserveCapacity(ids.count)

        await withTaskGroup(of: Actors?.self) { group in
            for id in ids {
                group.addTask {
                    do {
                        let rec: AirtableRecord<Actors> = try await Airtable.fetchById(
                            table: Airtable.actorsTable,
                            recordId: id
                        )
                        return rec.fields
                    } catch {
                        print("fetch actor by id failed:", id, error)
                        return nil
                    }
                }
            }

            for await actor in group {
                if let actor { result.append(actor) }
            }
        }

        // hop back to main actor to update @Published state
        await MainActor.run {
            self.actors = result
        }
    }

    private func fetchReviews() async {
        guard let movieRecordId = self.recordId else {
            reviews = []
            averageAppRatingText = "0.0"
            return
        }

        let formula = "({movie_id} = '\(movieRecordId)')"

        do {
            let recs = try await Airtable.listReviews(filterByFormula: formula)
            reviews = recs

            let rates = recs.compactMap { $0.fields.rate }
            let avg = rates.isEmpty ? 0.0 : (rates.reduce(0, +) / Double(rates.count))
            averageAppRatingText = String(format: "%.1f", avg)
        } catch {
            reviews = []
            averageAppRatingText = "0.0"
        }
    }
}

