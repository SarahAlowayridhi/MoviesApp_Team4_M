//
//  MoviesCenter.swift
//  MoviesApp_Team4_M
//
//  Created by Ghadeer Fallatah on 04/07/1447 AH.
//

import SwiftUI

struct MoviesCenter: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Search()
                HighRatedMovie() // data will be retrieved
                GenreSection()
            }
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
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("High Rated")  //this is a dummy (place holder )I will make it dynamic later
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 24)

            TabView {
                ForEach(0..<5) { _ in
                    Image("TopGunHR")  // same here place holders
                        .resizable()
                        .scaledToFill()
                        .frame(width: 366, height: 434)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
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
                        .foregroundColor(Color.yellow1)
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
                        .foregroundColor(Color.yellow1)
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
