//
//  SavedMoviesViewModel.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 15/07/1447 AH.
//


import Foundation
import Combine

@MainActor
class SavedMoviesViewModel: ObservableObject {

    @Published var savedMovies: [SavedMovieRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func getSavedMovies() async {

        // ⭐️ sara change:
        // توحيد مفتاح userId والتأكد أنه موجود
        guard let userId = UserDefaults.standard.string(forKey: "userId"),
              !userId.isEmpty else {
            self.savedMovies = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // ⭐️ sara change:
            // فلترة من السيرفر نفسه بدل الفلترة المحلية
            let formula = #"({user_id} = '\#(userId)')"#

            let records: [AirtableRecord<SavedMovieFields>] =
                try await Airtable.listRecords(
                    table: Airtable.savedMoviesTable,
                    filterByFormula: formula,
                    maxRecords: 100
                )

            // تحويل AirtableRecord إلى SavedMovieRecord
            self.savedMovies = records.map {
                SavedMovieRecord(id: $0.id, fields: $0.fields)
            }

        } catch {
            self.errorMessage = error.localizedDescription
            self.savedMovies = []
        }
    }
}

