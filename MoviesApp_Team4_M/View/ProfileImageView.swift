
//
//  ProfileImageView.swift .swift
//  MoviesApp_Team4_M
//
//  Created by Sarah Alowayridhi on 14/07/1447 AH.
//

import SwiftUI

struct ProfileImageView: View {

    let imageUrl: String?
    let size: CGFloat

    var body: some View {

        if let imageUrl,
           let url = URL(string: imageUrl) {

            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: size, height: size)
            .clipShape(Circle())

        } else {
            Image("profilephoto")
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }
}

