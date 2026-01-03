//
//  MovieDetailsVM.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 13/07/1447 AH.
//
import Foundation
import Combine
import Foundation

@MainActor
final class MovieDetailsVM: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var movieFields: MovieFields?
    @Published var recordId: String?

    @Published var actors: [Actors] = []
    @Published var director: Directors?
    @Published var reviews: [AirtableRecord<ReviewFields>] = []
    @Published var averageAppRatingText: String = "0.0"

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

    func actorImageURL(_ actor: Actors) -> URL? {
        URL(string: actor.image ?? "")
    }

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

    private func fetchDirector() async {
        guard let directorId = movieFields?.director?.first else {
            director = nil
            return
        }

        do {
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
        let ids = movieFields?.actors ?? []
        guard !ids.isEmpty else {
            actors = []
            return
        }

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

        actors = result
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
