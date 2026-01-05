//
//  AirtableDTOs.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 15/07/1447 AH.
//

import Foundation

// MARK: - Airtable response wrappers

struct AirtableRecord<T: Decodable>: Decodable {
    let id: String
    let createdTime: String
    let fields: T
}

struct AirtableListResponse<T: Decodable>: Decodable {
    let records: [AirtableRecord<T>]
}

// MARK: - Airtable table fields (DTOs)

struct AirtableMovieFields: Codable {
    let name: String?
    let genre: [String]?
    let language: [String]?
    let story: String?
    let IMDb_rating: Double?
    let runtime: String?

    let actors: [String]?
    let director: [String]?
    let reviews: [String]?

    // Added to match usage elsewhere (e.g., SavedMoviesViewModel uses poster)
    let poster: String?
}

struct AirtableReviewFields: Codable {
    let rate: Double?
    let review_text: String?
    let movie_id: String?
    let user_id: String?
}

struct MovieDirectorLinkFields: Codable {
    let movie_id: AirtableIDList?
    let director_id: AirtableIDList?
}

struct MovieActorLinkFields: Codable {
    let movie_id: AirtableIDList?
    let actor_id: AirtableIDList?
}

// MARK: - Airtable "can be String or [String]" helper

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

