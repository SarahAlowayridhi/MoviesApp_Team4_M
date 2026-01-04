//
//  Airtable.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 13/07/1447 AH.
//
import Foundation

enum Airtable {
    static let baseId = "appsfcB6YESLj4NCN"

    static let moviesTable = "movies"
    static let actorsTable = "actors"
    static let directorsTable = "directors"
    static let reviewsTable = "reviews"
    
    static let movieDirectorsTable = "movie_directors"
    static let movieActorsTable = "movie_actors"


    private static var token: String {
        let raw = APItoken.APItoken.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.lowercased().hasPrefix("bearer ") {
            return String(raw.dropFirst("bearer ".count))
        }
        return raw
    }

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

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
        if body != nil {
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

    private static func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        let url = try makeURL(path: path, queryItems: queryItems)
        let request = makeRequest(url: url, method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)
        return try decoder.decode(T.self, from: data)
    }

    private static func post(_ path: String, body: Data) async throws {
        let url = try makeURL(path: path)
        let request = makeRequest(url: url, method: "POST", body: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data: data)
    }

    static func fetchMovieById(recordId: String) async throws -> AirtableRecord<MovieFields> {
        let table = moviesTable.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? moviesTable
        return try await get("\(table)/\(recordId)")
    }

    static func fetchById<T: Decodable>(table: String, recordId: String) async throws -> AirtableRecord<T> {
        let encodedTable = table.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? table
        return try await get("\(encodedTable)/\(recordId)")
    }
    static func listRecords<T: Decodable>(
        table: String,
        filterByFormula: String,
        maxRecords: Int? = nil
    ) async throws -> [AirtableRecord<T>] {

        let encodedTable = table.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? table

        var items: [URLQueryItem] = [
            URLQueryItem(name: "filterByFormula", value: filterByFormula)
        ]
        if let maxRecords {
            items.append(URLQueryItem(name: "maxRecords", value: String(maxRecords)))
        }

        let response: AirtableListResponse<T> = try await get("\(encodedTable)", queryItems: items)
        return response.records
    }

}

extension Airtable {

    struct CreateRecordRequest<F: Encodable>: Encodable {
        let fields: F
    }

    struct ReviewCreateFields: Encodable {
        let rate: Double
        let review_text: String
        let movie_id: String
        let user_id: String?
    }

    static func createReview(fields: ReviewCreateFields) async throws {
        let table = reviewsTable.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? reviewsTable
        let payload = CreateRecordRequest(fields: fields)
        let body = try JSONEncoder().encode(payload)
        try await post("\(table)", body: body)
    }

    static func listReviews(filterByFormula: String, maxRecords: Int? = nil) async throws -> [AirtableRecord<ReviewFields>] {
        let table = reviewsTable.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? reviewsTable

        var items: [URLQueryItem] = [
            URLQueryItem(name: "filterByFormula", value: filterByFormula)
        ]
        if let maxRecords {
            items.append(URLQueryItem(name: "maxRecords", value: String(maxRecords)))
        }

        let response: AirtableListResponse<ReviewFields> = try await get("\(table)", queryItems: items)
        return response.records
    }
}

// MARK: - Airtable response wrappers

struct AirtableRecord<T: Decodable>: Decodable {
    let id: String
    let createdTime: String
    let fields: T
}

struct AirtableListResponse<T: Decodable>: Decodable {
    let records: [AirtableRecord<T>]
}

// MARK: - Airtable table fields

struct MovieFields: Codable {
    let name: String?
    let genre: [String]?
    let language: [String]?
    let story: String?
    let IMDb_rating: Double?
    let runtime: String?

    let actors: [String]?
    let director: [String]?
    let reviews: [String]?
}

struct ReviewFields: Codable {
    let rate: Double?
    let review_text: String?
    let movie_id: String?
    let user_id: String?
}


struct Movie: Codable {
    let name: String?
    let genre: [String]?
    let language: [String]?
    let story: String?
    let IMDb_rating: Double?
    let runtime: String?

    let actors: [String]?
    let director: [String]?
}

struct MovieDirectorLinkFields: Codable {
    let movie_id: AirtableIDList?
    let director_id: AirtableIDList?
}

struct MovieActorLinkFields: Codable {
    let movie_id: AirtableIDList?
    let actor_id: AirtableIDList?
}


enum AirtableIDList: Codable {
    case one(String)
    case many([String])

    var first: String? {
        switch self {
        case .one(let s): return s
        case .many(let arr): return arr.first
        }
    }

    var all: [String] {
        switch self {
        case .one(let s): return [s]
        case .many(let arr): return arr
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let arr = try? c.decode([String].self) {
            self = .many(arr)
        } else if let s = try? c.decode(String.self) {
            self = .one(s)
        } else {
            self = .many([])
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .one(let s): try c.encode(s)
        case .many(let arr): try c.encode(arr)
        }
    }
}
