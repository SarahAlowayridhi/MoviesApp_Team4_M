//
//  AppInfo.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 15/07/1447 AH.
//

import Foundation

// MARK: - App Models (UI-friendly)

struct Movie: Codable, Identifiable {
    // Use Airtable record id when you map it in the ViewModel
    var id: String = UUID().uuidString

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

struct Actors: Codable, Identifiable {
    let name: String?
    let image: String?
    var id: String { name ?? UUID().uuidString }
}

struct Directors: Codable {
    let name: String?
    let image: String?
}

struct Review: Codable, Identifiable {
    let rate: Double?
    let review_text: String?
    let movie_id: String?
    let user_id: String?
    var id: String { movie_id ?? UUID().uuidString }
}

// MARK: - Users (keep your existing shape)

struct UsersResponse: Codable {
    let records: [UserRecord]
}

struct UserRecord: Codable {
    let id: String
    let fields: User
}

struct User: Codable {
    let email: String?
    let password: String?
    let name: String
    let profile_image: String?
}
