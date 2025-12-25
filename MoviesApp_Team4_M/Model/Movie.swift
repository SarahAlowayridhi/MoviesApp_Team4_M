//
//  Movie.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 05/07/1447 AH.
//


import Foundation

struct Movie {
    let title: String
    let backdropName: String

    let duration: String
    let language: String
    let genre: String
    let ageRating: String

    let story: String
    let imdbRating: String

    let directorName: String
    let directorImageName: String

    let stars: [CastMember]
    let reviews: [Review]
    let averageAppRating: String
}

struct CastMember: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct Review: Identifiable {
    let id = UUID()
    let userName: String
    let userAvatarName: String
    let stars: Int
    let text: String
    let dateText: String
}
