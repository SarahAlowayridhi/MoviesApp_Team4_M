//
//  Movie.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 05/07/1447 AH.
//
import Foundation

struct Actors: Codable, Identifiable {
    let name: String?
    let image: String?

    // This is “good enough” for UI lists, but record-id is better if you later store it.
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
