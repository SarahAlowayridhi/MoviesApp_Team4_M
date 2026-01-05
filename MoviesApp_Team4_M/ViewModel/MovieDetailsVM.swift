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

    // ⭐️ sara change:
    // نحتفظ بالريفيوز الخام من Airtable
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

    var directorImageURL: URL? {
        guard let img = director?.image, !img.isEmpty else { return nil }
        return URL(string: img)
    }

    // ⭐️ sara change:
    // تمرير userId لمعرفة صاحب الريفيو
    var reviewsUI: [ReviewUI] {
        reviews.map { rec in
            let f = rec.fields
            return ReviewUI(
                id: rec.id,
                userId: f.user_id,
                userName: f.user_id ?? "User",
                stars: Int((f.rate ?? 0).rounded()),
                text: f.review_text ?? "",
                dateText: ""
            )
        }
    }

    // MARK: - Public Actions

    func load(recordId: String) async {
        isSaved = false
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

            // ⭐️ sara change:
            // التأكد من حالة الحفظ من السيرفر
            if let userId = UserDefaults.standard.string(forKey: "userId"),
               !userId.isEmpty {
                await checkIfSaved(userId: userId, movieRecordId: recordId)
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func actorImageURL(_ actor: Actors) -> URL? {
        guard let img = actor.image, !img.isEmpty else { return nil }
        return URL(string: img)
    }

    func prepareShare(recordId: String) {
        let title = titleText.isEmpty ? "Movie" : titleText
        let deepLink = URL(string: "moviesapp://movie/\(recordId)")!
        let message = "Check out \(title)"

        shareItems = [message, deepLink]
        isShareSheetPresented = true
    }

    // MARK: - Saved Movies

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

            // ⭐️ sara change:
            // بعد الحفظ نتحقق من السيرفر مباشرة
            await checkIfSaved(userId: userId, movieRecordId: movieRecordId)

        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    // ⭐️ sara change:
    // التحقق من حالة الحفظ من Airtable
    private func checkIfSaved(userId: String, movieRecordId: String) async {
        let formula = #"AND({user_id} = '\#(userId)', FIND('\#(movieRecordId)', ARRAYJOIN({movie_id})))"#

        do {
            let records: [AirtableRecord<SavedMovieFields>] =
                try await Airtable.listRecords(
                    table: Airtable.savedMoviesTable,
                    filterByFormula: formula,
                    maxRecords: 1
                )

            isSaved = !records.isEmpty
        } catch {
            isSaved = false
        }
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
            } catch { }
        }

        guard let movieRecordId = self.recordId else {
            director = nil
            return
        }

        let formula = #"movie_id="\#(movieRecordId)""#

        do {
            let links: [AirtableRecord<MovieDirectorLinkFields>] =
                try await Airtable.listRecords(
                    table: Airtable.movieDirectorsTable,
                    filterByFormula: formula,
                    maxRecords: 10
                )

            guard let directorId = links.compactMap({ $0.fields.director_id?.first }).first else {
                director = nil
                return
            }

            let rec: AirtableRecord<Directors> = try await Airtable.fetchById(
                table: Airtable.directorsTable,
                recordId: directorId
            )
            director = rec.fields
        } catch {
            director = nil
        }
    }

    private func fetchActors() async {
        let directActorIds = movieFields?.actors ?? []
        if !directActorIds.isEmpty {
            await fetchActorsByIds(directActorIds)
            return
        }

        guard let movieRecordId = self.recordId else {
            actors = []
            return
        }

        let formula = #"movie_id="\#(movieRecordId)""#

        do {
            let links: [AirtableRecord<MovieActorLinkFields>] =
                try await Airtable.listRecords(
                    table: Airtable.movieActorsTable,
                    filterByFormula: formula,
                    maxRecords: 50
                )

            let actorIds = links.compactMap { $0.fields.actor_id?.first }
            guard !actorIds.isEmpty else {
                actors = []
                return
            }

            await fetchActorsByIds(actorIds)
        } catch {
            actors = []
        }
    }

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
                        return nil
                    }
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
    // حذف الريفيو
    func deleteReview(reviewId: String) async {
        do {
            try await Airtable.deleteReview(reviewId: reviewId)
            await fetchReviews()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

