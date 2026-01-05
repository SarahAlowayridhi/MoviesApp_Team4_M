import SwiftUI

struct SignInView: View {

    @State private var email = ""
    @State private var password = ""

    @StateObject private var viewModel = SignInViewModel()
    @AppStorage("isLoggedIn") var isLoggedIn = false


    var body: some View {

        NavigationStack {

            ZStack(alignment: .top) {

                Image("Image")
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

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.white)

                            TextField("Enter your email", text: $email)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.white)

                            SecureField("Enter your password", text: $password)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                        }

                        Button {
                            let success = viewModel.signIn(
                                email: email,
                                password: password
                            )

                            if success {
                                isLoggedIn = true
                            } else {
                                print("❌ بيانات تسجيل الدخول غير صحيحة")
                            }

                        } label: {
                            Text("Sign in")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(14)
                        }
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
                .padding(.top, 180)
            }
            
            .navigationDestination(isPresented: $isLoggedIn) {
                FakeMovieCenter()
            }
            
            .onAppear {
                viewModel.getUsers()
            }
        }
    }
}

#Preview {
    SignInView()
}



