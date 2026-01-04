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

    // MARK: - Auth
    private static var token: String {
        let raw = APItoken.APItoken.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.lowercased().hasPrefix("bearer ") {
            return String(raw.dropFirst("bearer ".count))
        }
        return raw
    }

    // MARK: - JSON
    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    // MARK: - URL + Request
    private static func makeURL(path: String, queryItems: [URLQueryItem]? = nil) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.airtable.com"
        components.path = "/v0/\(baseId)/\(path)"
        components.queryItems = queryItems

        guard let url = components.url else { throw URLError(.badURL) }
        return url
    }

    private static func makeRequest(url: URL, method: String, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        return request
    }

    private static func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "Airtable",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
            )
        }
    }

    // MARK: - Generic calls
    static func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        let url = try makeURL(path: path, queryItems: queryItems)
        let request = makeRequest(url: url, method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)
        return try decoder.decode(T.self, from: data)
    }

    static func post(_ path: String, body: Data) async throws {
        let url = try makeURL(path: path)
        let request = makeRequest(url: url, method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)
    }

    // MARK: - Helpers
    static func encodeTable(_ table: String) -> String {
        table.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? table
    }
}
