
//
//  ProfileViewModel.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 15/07/1447 AH.
//


import Foundation
import Combine

class ProfileViewModel: ObservableObject {

    @Published var user: UserRecord?

    func getUser() {

        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            return
        }

        let urlString = "https://api.airtable.com/v0/appsfcB6YESLj4NCN/users/\(userId)"

        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(APItoken.APItoken)" , forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in

            guard let data = data else { return }

            let decodedUser = try? JSONDecoder().decode(UserRecord.self, from: data)

            DispatchQueue.main.async {
                self.user = decodedUser
            }

        }
        .resume()
    }
    
    func updateUser(name: String, completion: @escaping (Bool) -> Void) {

        guard
            let userId = UserDefaults.standard.string(forKey: "userId"),
            let currentUser = user
        else {
            completion(false)
            return
        }

        let urlString = "https://api.airtable.com/v0/appsfcB6YESLj4NCN/users/\(userId)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(APItoken.APItoken)" , forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "fields": [
                "name": name,
                "email": currentUser.fields.email ?? "",
                "password": currentUser.fields.password ?? "",
                "profile_image": currentUser.fields.profile_image ?? ""
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            let updatedUser = try? JSONDecoder().decode(UserRecord.self, from: data)

            DispatchQueue.main.async {
                self.user = updatedUser
                completion(true)
            }

        }.resume()
    }


}


