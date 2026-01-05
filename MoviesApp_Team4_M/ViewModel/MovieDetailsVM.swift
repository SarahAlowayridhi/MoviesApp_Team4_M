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

    // ⭐️ sara change:
    // أضفنا userId داخل ReviewUI عشان نقدر نحدد صاحب الريفيو
    var reviewsUI: [ReviewUI] {
        reviews.map { rec in
            let f = rec.fields
            return ReviewUI(
                id: rec.id,
                userId: f.user_id,          // ⭐️ sara change
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
        if let directorId = movieFields?.director?.first {
            do {
                let rec: AirtableRecord<Directors> = try await Airtable.fetchById(
                    table: Airtable.directorsTable,
                    recordId: directorId
                )
                director = rec.fields
                return
            } catch {
                print("fetchDirector failed:", error)
            }
        }
    }

    private func fetchActors() async {
        let directActorIds = movieFields?.actors ?? []
        if !directActorIds.isEmpty {
            await fetchActorsByIds(directActorIds)
            return
        }
    }

    nonisolated private func fetchActorsByIds(_ ids: [String]) async {
        var result: [Actors] = []

        await withTaskGroup(of: Actors?.self) { group in
            for id in ids {
                group.addTask {
                    try? await Airtable.fetchById(
                        table: Airtable.actorsTable,
                        recordId: id
                    ).fields
                }
            }

            for await actor in group {
                if let actor { result.append(actor) }
            }
        }

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

    // ⭐️ sara change:
    // دالة حذف الريفيو + إعادة تحميل الريفيوهات
    func deleteReview(reviewId: String) async {
        do {
            try await Airtable.deleteReview(reviewId: reviewId)
            await fetchReviews()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

