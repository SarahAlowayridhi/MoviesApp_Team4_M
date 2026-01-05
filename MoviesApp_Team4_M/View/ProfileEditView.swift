//
//  ProfileEditView.swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 10/07/1447 AH.
//



import SwiftUI

struct ProfileEditView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProfileViewModel()

    let user: UserRecord?

    @State private var firstName: String = ""
    @State private var lastName: String = ""

    var body: some View {

        VStack(spacing: 24) {

            // MARK: - Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                    .foregroundColor(.yellow)
                }

                Spacer()

                Text("Edit profile")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    saveChanges()
                } label: {
                    Text("Save")
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal)

            Divider()

            // MARK: - Profile Image (UI only)
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 110, height: 110)

                Image(systemName: "camera")
                    .font(.title)
                    .foregroundColor(.yellow)
            }
            .padding(.top, 12)

            // MARK: - Form
            VStack(spacing: 0) {

                HStack {
                    Text("First name")
                        .foregroundColor(.white)

                    Spacer()

                    TextField("First name", text: $firstName)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                }
                .padding()

                Divider()

                HStack {
                    Text("Last name")
                        .foregroundColor(.white)

                    Spacer()

                    TextField("Last name", text: $lastName)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding()
            }
            .background(Color.gray.opacity(0.35))
            .cornerRadius(16)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 8)
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.user = user   // 🔑 أهم سطر
               setupInitialData()        }
    }

    // MARK: - Helpers

    private func setupInitialData() {
        let fullName = user?.fields.name ?? ""
        let parts = fullName.split(separator: " ")

        firstName = parts.first.map(String.init) ?? ""
        lastName = parts.dropFirst().joined(separator: " ")
    }

    private func saveChanges() {
        let fullName = "\(firstName) \(lastName)"

        viewModel.updateUser(name: fullName) { success in
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileEditView(user: nil)
    }
}



