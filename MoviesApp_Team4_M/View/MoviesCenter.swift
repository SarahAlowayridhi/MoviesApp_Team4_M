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
        NavigationStack {
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
            .background(Color.black.ignoresSafeArea())
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
}

struct Search: View {
    @State private var searchText = ""
    @StateObject private var viewModel = ProfileViewModel()

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

                    NavigationLink {
                        ProfileView()
                    } label: {
                        ProfileImageView(
                            imageUrl: viewModel.user?.fields.profile_image,
                            size: 65
                        )
                    }
                    .buttonStyle(.plain)
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
        
        .task {
            await viewModel.getUser()
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

            TabView {
                ForEach(movies) { movie in
                    NavigationLink {
                        MovieDetails(
                            recordId: movie.id,
                            fallbackPosterURL: movie.fields.poster
                        )
                    } label: {
                        AsyncImage(url: URL(string: movie.fields.poster ?? "")) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            default:
                                Color.gray.opacity(0.3)
                            }
                        }
                    }

                    .buttonStyle(.plain)
                    .padding(.bottom, 50)
                }
            }
            .frame(height: 460)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
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
