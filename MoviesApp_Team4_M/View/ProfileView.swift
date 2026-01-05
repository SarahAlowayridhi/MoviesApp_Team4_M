import SwiftUI

struct ProfileView: View {

    @Environment(\.dismiss) private var dismiss

    // ViewModel خاص ببيانات المستخدم
    @StateObject private var viewModel = ProfileViewModel()

    // ViewModel خاص بالأفلام المحفوظة
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

            // MARK: - Profile card
            NavigationLink {
                ProfileInfoView(user: viewModel.user)
            } label: {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.35))
                        .frame(height: 110)
                        .cornerRadius(16)

                    HStack(spacing: 16) {

                        // Profile image
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 80)

                            ProfileImageView(
                                imageUrl: viewModel.user?.fields.profile_image,
                                size: 65
                            )
                        }

                        // Name & email
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

            // MARK: - Saved Movies Content
            if savedMoviesVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if savedMoviesVM.savedMovieCards.isEmpty {
                VStack(spacing: 12) {
                    Image("movieisme logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 73, height: 44)
                        .foregroundColor(.gray.opacity(0.6))

                    Text("No saved movies yet,\nstart saving your favourites")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            } else {

                // ⭐️ Carousel أفقي للأفلام المحفوظة
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(savedMoviesVM.savedMovieCards) { movie in
                            savedMovieCard(movie)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)

        // MARK: - API Calls
        .task {
            viewModel.getUser()
            await savedMoviesVM.getSavedMovies()
        }
    }

    // MARK: - Saved Movie Card UI

    private func savedMovieCard(_ movie: SavedMovieCard) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            ZStack(alignment: .topLeading) {
                // Poster
                if let url = movie.posterURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Color.gray.opacity(0.3)
                        }
                    }
                } else {
                    Color.gray.opacity(0.3)
                }

                // Saved badge
                Text("Saved")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow)
                    .clipShape(Capsule())
                    .padding(6)
            }
            .frame(width: 120, height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Movie title
            Text(movie.title)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 120)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}

