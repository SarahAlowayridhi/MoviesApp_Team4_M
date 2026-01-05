import SwiftUI

struct SignInView: View {

    @State private var email = ""
    @State private var password = ""

    @State private var emailFocused = false
    @State private var passwordFocused = false
    @State private var showError = false

    @StateObject private var viewModel = SignInViewModel()
    @AppStorage("isLoggedIn") var isLoggedIn = false

    // MARK: - Validation
    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var body: some View {

        NavigationStack {
            ZStack(alignment: .top) {

                Image("signinbackground")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .top)

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.15),
                        Color.black.opacity(1.56)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sign in")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("You'll find what you're looking for in the \nocean of movies")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.top, 140)
                    .padding(.horizontal, 24)

                    // MARK: - Form
                    VStack(alignment: .leading, spacing: 20) {

                        // MARK: - Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .foregroundColor(.white)

                            TextField("Enter your email", text: $email)
                                .padding()
                                .background(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            showError ? Color.red :
                                            emailFocused ? Color.yellow : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                                .cornerRadius(12)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .onTapGesture {
                                    emailFocused = true
                                    passwordFocused = false
                                }
                        }

                        // MARK: - Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .foregroundColor(.white)

                            SecureField("Enter your password", text: $password)
                                .padding()
                                .background(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            showError ? Color.red :
                                            passwordFocused ? Color.yellow : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                                .cornerRadius(12)
                                .onTapGesture {
                                    passwordFocused = true
                                    emailFocused = false
                                }
                        }

                        // MARK: - Error message
                        if showError {
                            Text("Invalid email or password")
                                .foregroundColor(.red)
                                .font(.caption)
                        }

                        // MARK: - Sign in button
                        Button {
                            let success = viewModel.signIn(
                                email: email,
                                password: password
                            )

                            if success {
                                showError = false
                                isLoggedIn = true
                            } else {
                                showError = true
                            }

                        } label: {
                            Text("Sign in")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    canSubmit ? Color.yellow : Color.gray
                                )
                                .cornerRadius(14)
                        }
                        .disabled(!canSubmit)
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
                .padding(.top, 180)
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                MoviesCenter()
            }
            .task {
                await viewModel.getUsers()
            }
        }
    }
}

#Preview {
    SignInView()
}

