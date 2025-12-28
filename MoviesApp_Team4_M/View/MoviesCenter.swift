
//  MoviesCenter.swift
//  MoviesApp_Team4_M
//
//  Created by Ghadeer Fallatah on 04/07/1447 AH.
//

import SwiftUI

struct MoviesCenter: View {

    // Dummy movie used for navigation
    private let sampleMovie = Movie(
        title: "Shawshank",
        backdropName: "shawshank",
        duration: "2 hours 22 mins",
        language: "English",
        genre: "Drama",
        ageRating: "+15",
        story: "Synopsis. In 1947, Andy Dufresne (Tim Robbins), a banker in Maine, is convicted of murdering his wife and her lover...",
        imdbRating: "9.3 / 10",
        directorName: "Frank Darabont",
        directorImageName: "director",
        stars: [
            CastMember(name: "Tim Robbins", imageName: "tim"),
            CastMember(name: "Morgan Freeman", imageName: "morgan"),
            CastMember(name: "Bob Gunton", imageName: "bob")
        ],
        reviews: [
            Review(
                userName: "Afnan Abdullah",
                userAvatarName: "user1",
                stars: 4,
                text: "This is an engagingly simple, good-hearted film, with just enough darkness around the edges",
                dateText: "September 13, 2021"
            )
        ],
        averageAppRating: "4.8"
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Search()
                HighRatedMovie(movieToOpen: sampleMovie)
                GenreSection(movieToOpen: sampleMovie)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true) // optional: if you don’t want a back arrow here
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct Search: View {
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Movies Center")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                NavigationLink {
                    ProfileView()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 41, height: 41)

                        Image("ProfileIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35, height: 35)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField(
                    "",
                    text: $searchText,
                    prompt: Text("Search for Movie name , actors ...")
                        .foregroundColor(.gray)
                )
                .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .frame(width: 380, height: 38)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.4))
            )
            .padding(.horizontal, 16)
        }
    }
}


struct HighRatedMovie: View {
    let movieToOpen: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("High Rated")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 24)

            TabView {
                ForEach(0..<5, id: \.self) { _ in
                    NavigationLink {
                        MovieDetails(movie: movieToOpen)
                    } label: {
                        Image("TopGunHR")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 366, height: 434)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.bottom, 50)
                    }
                    .buttonStyle(.plain) // keeps your image style (no blue tint)
                }
            }
            .frame(height: 460)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        }
        .padding(.horizontal, 16)
    }
}

struct GenreSection: View {
    let movieToOpen: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Drama Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Drama")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("Show more")
                        .font(.system(size: 14))
                        .foregroundColor(Color.yellow1)
                }

                HStack(spacing: 16) {
                    movieImageLink("Drama1")
                    movieImageLink("Drama2")
                }
            }

            // Comedy Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Comedy")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("Show more")
                        .font(.system(size: 14))
                        .foregroundColor(Color.yellow1)
                }

                HStack(spacing: 16) {
                    movieImageLink("Comedy1")
                    movieImageLink("Comedy2")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    @ViewBuilder
    private func movieImageLink(_ imageName: String) -> some View {
        NavigationLink {
            MovieDetails(movie: movieToOpen)
        } label: {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 177, height: 266)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MoviesCenter()
    }
}
