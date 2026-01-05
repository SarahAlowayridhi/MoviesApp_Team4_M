import SwiftUI

struct ProfileView: View {

    @Environment(\.dismiss) private var dismiss

    // 🔹 ViewModel خاص ببيانات المستخدم (profile)
    @StateObject private var viewModel = ProfileViewModel()

    // 🔹 ViewModel خاص بالأفلام المحفوظة (saved_movies)
    @StateObject private var savedMoviesVM = SavedMoviesViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // MARK: - Back button
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.yellow)

                    Text("Back")
                        .font(.title3)
                        .foregroundColor(.yellow)
                }
            }

            // MARK: - Title
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // MARK: - Profile card (Navigation to ProfileInfoView)
            NavigationLink {
                ProfileInfoView(user: viewModel.user)
            } label: {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.35))
                        .frame(height: 110)
                        .cornerRadius(16)

                    HStack(spacing: 16) {

                        // 🔹 Profile image from API (or fallback)
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 80)

                            ProfileImageView(
                                imageUrl: viewModel.user?.fields.profile_image,
                                size: 65
                            )
                        }

                        // 🔹 User name & email
                        VStack(alignment: .leading, spacing: 6) {
                            Text(viewModel.user?.fields.name ?? "—")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text(viewModel.user?.fields.email ?? "—")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }
            }
            .buttonStyle(.plain)

            // MARK: - Saved Movies Title
            Text("Saved movies")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.top, 8)

            Spacer()

            // MARK: - Saved Movies Content
            if savedMoviesVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if savedMoviesVM.savedMovies.isEmpty {
                VStack(spacing: 12) {
                    Image("movieisme logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 73.07, height: 43.66)
                        .foregroundColor(.gray.opacity(0.6))

                    Text("No saved movies yet, start save\nyour favourites")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            } else {
                // 🔹 مؤقتًا نعرض عدد الأفلام (إثبات أن API شغال)
                Text("You have \(savedMoviesVM.savedMovies.count) saved movies")
                    .font(.caption)
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)

        // MARK: - API Calls
        // ⭐️ sara change:
        // - جلب بيانات المستخدم
        // - جلب الأفلام المحفوظة باستخدام async / await
        .task {
            viewModel.getUser()
            await savedMoviesVM.getSavedMovies()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}

