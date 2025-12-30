//
//  Users.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 08/07/1447 AH.
//

import Foundation

struct UsersResponse: Decodable {
    let records: [UserRecord]
}

struct UserRecord: Decodable { //عندنا مجموعة من المستخدمين
    let id: String
    let fields: User
}

struct User: Decodable {
    let email: String
    let password: String
}




