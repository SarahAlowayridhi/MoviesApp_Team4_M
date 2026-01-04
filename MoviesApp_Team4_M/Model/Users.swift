//
//  Users.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 08/07/1447 AH.
//

import Foundation

struct UsersResponse: Codable {
    let records: [UserRecord]
}

struct UserRecord: Codable { //عندنا مجموعة من المستخدمين
    let id: String
    let fields: User
}

struct User: Codable {
    let email: String?
    let password: String?
    let name: String
    let profile_image: String?

}




