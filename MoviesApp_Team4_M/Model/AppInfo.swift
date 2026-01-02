//
//  Movie.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 05/07/1447 AH.
//
import Foundation

struct Movie: Codable {
    let name: String
    let createdTime: String
    let genre: [String] // array
    let language: [String] // array
    let poster: String
    let story: String
    let rating: String? 
    let IMDb_rating: Double
    let runtime: String
}
    
struct Actors: Codable {
        var id = UUID()
        let name: String
        let image: String //link 
    }
    
struct Directors: Codable {
        var id = UUID()
        let name: String
        let image: String //link
    }

struct Review: Identifiable {
    var id = UUID()
    var user_id = UUID()
    let rate: Double
    let review_text: String
    
   
}
