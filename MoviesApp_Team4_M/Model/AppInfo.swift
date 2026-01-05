//
//  AppInfo.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 15/07/1447 AH.
//
import Foundation


struct MoviesResponse: Codable {
    let records: [MovieRecord]
}

struct MovieRecord: Codable, Identifiable {
    let id: String
    let fields: Movie
}

struct Movie: Codable {
    let name: String?
    let createdTime: String?
    let genre: [String]?
    let language: [String]?
    let poster: String?
    let story: String?
    let rating: String?
    let IMDb_rating: Double?
    let runtime: String?
    
    enum CodingKeys: String, CodingKey {
        case name, createdTime, genre, language, poster, story, rating, IMDb_rating, runtime
    }
}

struct ActorsResponse: Codable {
    let records: [ActorRecord]
}


struct ActorRecord: Codable, Identifiable {
    let id: String
    let fields: Actors
}

struct Actors: Codable {
    let name: String?
    let image: String?
    
    
    enum CodingKeys: String, CodingKey {
        case name, image
    }
}

struct DirectorsResponse: Codable {
    let records: [DirectorRecord]
}

struct DirectorRecord: Codable, Identifiable {
    let id: String
    let fields: Directors
}

struct Directors: Codable {
    let name: String?
    let image: String?

  enum CodingKeys: String, CodingKey {
    case name, image
}
    
  }


struct ReviewsResponse: Codable {
    let records: [ReviewRecord]
}

struct ReviewRecord: Codable, Identifiable {
    let id: String
    let fields: Review
}

struct Review: Codable {
    let rate: Double?
    let review_text: String?
    let movie_id: String?
    let user_id: String?
    
    enum CodingKeys: String, CodingKey {
        case rate, review_text, movie_id, user_id
    }
}


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

// Response wrapper
struct SavedMoviesResponse: Decodable {
    let records: [SavedMovieRecord]
}

// Single record
struct SavedMovieRecord: Decodable, Identifiable {
    let id: String
    let fields: SavedMovieFields
}

// Fields inside each record
struct SavedMovieFields: Decodable {
    let user_id: String
    let movie_id: [String]
}

