//
//  Airtable.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 13/07/1447 AH.
//

import Foundation

enum Airtable {
    static let baseId = "appsfcB6YESLj4NCN"
    static let tableName = "movies"

    // Minimal safety: works whether APItoken has "Bearer " or not.
    private static var token: String {
        let raw = APItoken.APItoken.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.lowercased().hasPrefix("bearer ") {
            return String(raw.dropFirst("bearer ".count))
        }
        return raw
    }

    static func fetchMovieById(recordId: String) async throws -> AirtableRecord<MovieFields> {
        let table = tableName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tableName
        let url = URL(string: "https://api.airtable.com/v0/\(baseId)/\(table)/\(recordId)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // Only “hard part” comment: print this when debugging 401/403/404
        // print("Airtable status:", http.statusCode, String(data: data, encoding: .utf8) ?? "")

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "Airtable",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
            )
        }

        return try JSONDecoder().decode(AirtableRecord<MovieFields>.self, from: data)
    }
}

// Generic single-record response from Airtable
struct AirtableRecord<T: Decodable>: Decodable {
    let id: String
    let createdTime: String
    let fields: T
}

// Fields for Movies table
struct MovieFields: Codable {
    let name: String?
    let genre: [String]?
    let language: [String]?
    let story: String?
    let IMDb_rating: Double?
    let runtime: String?
}
