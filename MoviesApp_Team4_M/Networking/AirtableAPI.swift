//
//  AirtableAPI.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 15/07/1447 AH.
//

import Foundation

extension Airtable {

    // MARK: - Generic fetchers
    static func fetchById<T: Decodable>(table: String, recordId: String) async throws -> AirtableRecord<T> {
        let encodedTable = encodeTable(table)
        return try await get("\(encodedTable)/\(recordId)")
    }

    static func listRecords<T: Decodable>(
        table: String,
        filterByFormula: String,
        maxRecords: Int? = nil
    ) async throws -> [AirtableRecord<T>] {

        let encodedTable = encodeTable(table)

        var items: [URLQueryItem] = [
            URLQueryItem(name: "filterByFormula", value: filterByFormula)
        ]
        if let maxRecords {
            items.append(URLQueryItem(name: "maxRecords", value: String(maxRecords)))
        }

        let response: AirtableListResponse<T> = try await get(encodedTable, queryItems: items)
        return response.records
    }

    // MARK: - Movies
    static func fetchMovieById(recordId: String) async throws -> AirtableRecord<AirtableMovieFields> {
        let table = encodeTable(moviesTable)
        return try await get("\(table)/\(recordId)")
    }

    // MARK: - Create wrappers
    struct CreateRecordRequest<F: Encodable>: Encodable {
        let fields: F
    }

    // MARK: - Reviews
    struct ReviewCreateFields: Encodable {
        let rate: Double
        let review_text: String
        let movie_id: String
        let user_id: String?
    }

    static func createReview(fields: ReviewCreateFields) async throws {
        let table = encodeTable(reviewsTable)
        let payload = CreateRecordRequest(fields: fields)
        let body = try JSONEncoder().encode(payload)
        try await post(table, body: body)
    }

    static func listReviews(
        filterByFormula: String,
        maxRecords: Int? = nil
    ) async throws -> [AirtableRecord<AirtableReviewFields>] {

        try await listRecords(
            table: reviewsTable,
            filterByFormula: filterByFormula,
            maxRecords: maxRecords
        )
    }

    // MARK: - Saved Movies
    struct SavedMovieCreateFields: Encodable {
        let user_id: String
        let movie_id: [String]   // Airtable linked record expects array
    }

    static func createSavedMovie(fields: SavedMovieCreateFields) async throws {
        let table = encodeTable(savedMoviesTable)
        let payload = CreateRecordRequest(fields: fields)
        let body = try JSONEncoder().encode(payload)
        try await post(table, body: body)
    }
}
