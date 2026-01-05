//
//  AirtableClient.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 15/07/1447 AH.
//

import Foundation

enum Airtable {

    // MARK: - Config

    static let baseId = "appsfcB6YESLj4NCN"

    static let moviesTable = "movies"
    static let actorsTable = "actors"
    static let directorsTable = "directors"
    static let reviewsTable = "reviews"
    static let movieDirectorsTable = "movie_directors"
    static let movieActorsTable = "movie_actors"
    static let savedMoviesTable = "saved_movies"

    // MARK: - JSON

    private static let decoder: JSONDecoder = {
        JSONDecoder()
    }()

    // MARK: - URL Builder

    private static func makeURL(path: String, queryItems: [URLQueryItem]? = nil) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.airtable.com"
        components.path = "/v0/\(baseId)/\(path)"
        components.queryItems = queryItems

        guard let url = components.url else { throw URLError(.badURL) }
        return url
    }

    // MARK: - Generic Calls (now via APIRequester)

    static func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        let url = try makeURL(path: path, queryItems: queryItems)
        let data = try await APIRequester.fetch(from: url, method: .get)
        return try decoder.decode(T.self, from: data)
    }

    static func post(_ path: String, body: Data) async throws {
        let url = try makeURL(path: path)
        _ = try await APIRequester.fetch(from: url, method: .post, body: body)
    }

    // MARK: - Helpers

    static func encodeTable(_ table: String) -> String {
        table.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? table
    }
}
