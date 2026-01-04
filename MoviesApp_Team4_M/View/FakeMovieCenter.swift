//
//  FakeMovieCenter.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 13/07/1447 AH.
//

import SwiftUI

struct FakeMovieCenter: View {

    private let testMovieId = "recyOSEgvOjALkHPq"

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Fake Movie Center")
                    .font(.title.bold())

                NavigationLink {
                    MovieDetails(recordId: testMovieId)
                } label: {
                    Text("Movie Details")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                
            }
            .padding()
        }
    }
}

#Preview {
    FakeMovieCenter()
}
