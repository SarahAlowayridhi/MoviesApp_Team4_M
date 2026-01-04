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
    static func fetch(from url: URL, method: HTTPMethod = .get, body: Data? = nil) async throws -> Data {
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        request.setValue("Bearer \(APItoken.APItoken)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return data
    }
}
