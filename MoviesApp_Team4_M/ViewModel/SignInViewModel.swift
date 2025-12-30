//
//  SignInViewModel.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 10/07/1447 AH.
//


import Foundation
import Combine

class SignInViewModel: ObservableObject {

    //  نخزن المستخدمين
    @Published var users: [UserRecord] = []

    //  نجيب المستخدمين من API
    func getUsers() {

        guard let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/users") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print(APItoken.APItoken)
        URLSession.shared.dataTask(with: request) { data, response, error in

            guard let data = data else { return }

            let decodedResponse = try? JSONDecoder().decode(UsersResponse.self, from: data)

            DispatchQueue.main.async {
                self.users = decodedResponse?.records ?? []
            }

        }.resume()
    }

    //  التحقق من تسجيل الدخول
    func signIn(email: String, password: String) -> Bool {

        let user = users.first { record in
            record.fields.email == email &&
            record.fields.password == password
        }

        return user != nil
    }
}
