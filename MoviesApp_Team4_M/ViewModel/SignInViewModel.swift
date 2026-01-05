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
    @Published var currentUser: UserRecord?

    //  نجيب المستخدمين من API
    func getUsers() {

        guard let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/users") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        request.setValue(APItoken.APItoken , forHTTPHeaderField: "Authorization")
        
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

        if let user = users.first(where: { record in

            guard
                let userEmail = record.fields.email,
                let userPassword = record.fields.password
            else {
                return false // تجاهل المستخدم الناقص
            }

            return userEmail == email && userPassword == password
        }) {

            currentUser = user
            UserDefaults.standard.set(user.id, forKey: "userId")
            return true
        }

        return false
    }

}


