//
//  SavedMoviesViewModel.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 15/07/1447 AH.
//

import Foundation
import Combine

// MARK: - UI Model

struct SavedMovieCard: Identifiable {
    let id: String           // movie record id
    let title: String
    let posterURL: URL?
}

@MainActor
class SavedMoviesViewModel: ObservableObject {

    // raw saved_movies records
    @Published var savedMovies: [SavedMovieRecord] = []

    // UI-ready cards (للبروفايل)
    @Published var savedMovieCards: [SavedMovieCard] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Public API

    func getSavedMovies() async {

        // توحيد مفتاح userId والتأكد أنه موجود
        guard let userId = UserDefaults.standard.string(forKey: "userId"),
              !userId.isEmpty else {
            self.savedMovies = []
            self.savedMovieCards = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // فلترة من السيرفر نفسه
            let formula = #"({user_id} = '\#(userId)')"#

            let records: [AirtableRecord<SavedMovieFields>] =
                try await Airtable.listRecords(
                    table: Airtable.savedMoviesTable,
                    filterByFormula: formula,
                    maxRecords: 100
                )

            // حفظ الـ raw records
            self.savedMovies = records.map {
                SavedMovieRecord(id: $0.id, fields: $0.fields)
            }

            // بناء بيانات العرض (name + poster)
            await buildSavedMovieCards(from: records)

        } catch {
            self.errorMessage = error.localizedDescription
            self.savedMovies = []
            self.savedMovieCards = []
        }
    }

    // MARK: - Helpers

    /// نحول saved_movies → movie cards (للواجهة)
    private func buildSavedMovieCards(
        from records: [AirtableRecord<SavedMovieFields>]
    ) async {

        var cards: [SavedMovieCard] = []
        cards.reserveCapacity(records.count)

        for record in records {

            // نأخذ أول movie_id (كل سجل مربوط بفيلم واحد)
            guard let movieId = record.fields.movie_id.first else {
                continue
            }

            do {
                // جلب تفاصيل الفيلم (نفس طريقة MovieCenter)
                let movieRecord: AirtableRecord<Movie> =
                    try await Airtable.fetchById(
                        table: Airtable.moviesTable,
                        recordId: movieId
                    )

                let title = movieRecord.fields.name ?? "Unknown"
                let posterURL = URL(string: movieRecord.fields.poster ?? "")

                cards.append(
                    SavedMovieCard(
                        id: movieId,
                        title: title,
                        posterURL: posterURL
                    )
                )

            } catch {
                // لو فشل جلب فيلم معيّن، نتجاهله
                continue
            }
        }

        // ⭐️ sara change:
        // إزالة التكرار — كل فيلم يظهر مرة وحدة فقط
        var unique: [SavedMovieCard] = []
        var seen = Set<String>()

        for card in cards {
            if seen.insert(card.id).inserted {
                unique.append(card)
            }
        }

        self.savedMovieCards = unique
    }
}

