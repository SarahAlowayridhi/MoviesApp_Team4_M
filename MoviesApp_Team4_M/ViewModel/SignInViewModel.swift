//
//  SignInViewModel.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 10/07/1447 AH.
//


import Foundation
import Combine

@MainActor
class SignInViewModel: ObservableObject {


    @Published var users: [UserRecord] = []
    @Published var currentUser: UserRecord?
    @Published var isLoading = false
    @Published var errorMessage: String?


    func getUsers() async {

        guard let url = URL(string: "https://api.airtable.com/v0/appsfcB6YESLj4NCN/users") else {
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(APItoken.APItoken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(UsersResponse.self, from: data)
            self.users = decodedResponse.records
        } catch {
            self.users = []
            self.errorMessage = error.localizedDescription
        }
    }


    func signIn(email: String, password: String) -> Bool {

        // تأكيد أن المستخدمين محمّلين قبل تسجيل الدخول
        guard !users.isEmpty else {
            errorMessage = "Users not loaded yet."
            return false
        }

        guard let user = users.first(where: { record in
            guard
                let userEmail = record.fields.email,
                let userPassword = record.fields.password
            else {
                return false
            }
            return userEmail == email && userPassword == password
        }) else {
            errorMessage = "Invalid email or password."
            return false
        }

        currentUser = user

        // توحيد مفتاح userId في كل المشروع
        UserDefaults.standard.set(user.id, forKey: "userId")

        return true
    }
}

