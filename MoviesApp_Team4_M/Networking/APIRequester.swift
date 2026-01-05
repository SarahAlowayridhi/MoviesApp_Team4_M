//
//  APIRequester.swift
//  MoviesApp_Team4_M
//
//  Created by Ghadeer Fallatah on 15/07/1447 AH.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

struct APIRequester {

    private static var cleanedToken: String {
        let raw = APItoken.APItoken.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.lowercased().hasPrefix("bearer ") {
            return String(raw.dropFirst("bearer ".count))
        }
        return raw
    }

    static func fetch(
        from url: URL,
        method: HTTPMethod = .get,
        body: Data? = nil
    ) async throws -> Data {

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        request.setValue("Bearer \(cleanedToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        // Validate status code (so your errors are meaningful)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(http.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "APIRequester",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(bodyText)"]
            )
        }

        return data
    }
}
