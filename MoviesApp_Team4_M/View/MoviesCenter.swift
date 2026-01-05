//
//  ContentView.swift
//  MoviesClone
//
//  Created by Ghadeer Fallatah on 15/07/1447 AH.
//
//
import SwiftUI

struct MoviesCenter: View {
    @StateObject private var moviesVm = MovieCenterVM()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Search()
                
                if moviesVm.isLoading {
                    ProgressView("Loading movies...")
                        .padding()
                } else if let error = moviesVm.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    HighRatedMovie(movies: moviesVm.movies)
                }
                
                GenreSection()
            }
        }
        .task {
            await moviesVm.fetchMovies()
        }
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
    let movies: [MovieRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("High Rated")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 24)
            
            Text("Movies count: \(movies.count)")
                .foregroundColor(.white)
                .font(.caption)

            if movies.isEmpty {
                Text("No movies loaded")
                    .foregroundColor(.gray)
                    .frame(height: 460)
            } else {
                TabView {
                    ForEach(movies) { movie in
                        VStack {
                            Text("Movie: \(movie.fields.name)")
                                .foregroundColor(.white)
                            Text("Poster URL: \(movie.fields.poster ?? "-")")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            AsyncImage(url: URL(string: movie.fields.poster ?? "")) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 366, height: 434)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 366, height: 434)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                case .failure(let error):
                                    VStack {
                                        Text("Image failed to load")
                                            .foregroundColor(.red)
                                        Text(error.localizedDescription)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    .frame(width: 366, height: 434)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        .padding(.bottom, 50)
                    }
                }
                .frame(height: 460)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            }
        }
        .padding(.horizontal, 16)
    }
}

struct GenreSection: View {
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
                        .foregroundColor(Color.yellow)
                }
                
                HStack(spacing: 16) {
                    Image("Drama1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 177, height: 266)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    Image("Drama2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 177, height: 266)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
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
                        .foregroundColor(Color.yellow)
                }
                
                HStack(spacing: 16) {
                    Image("Comedy1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 177, height: 266)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    Image("Comedy2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 177, height: 266)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }
}

#Preview {
    MoviesCenter()
}

