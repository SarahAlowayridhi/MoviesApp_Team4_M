//
//  MovieDetails.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 05/07/1447 AH.
//


import SwiftUI

//Shared Colors (file-scope)
extension Color {
    static let iconColor = Color(red: 243/255, green: 204/255, blue: 79/255)
}

struct MovieDetails: View {
    let movie: Movie

    //Scroll tracking for animated box
    @State private var scrollY: CGFloat = 0
    private let headerMax: CGFloat = 420
    private let headerMin: CGFloat = 120

    var body: some View {
        ScrollView(showsIndicators: false) {

            header
            
            VStack(alignment: .leading, spacing: 18) {

                Text(movie.title)
                    .font(.system(size: 32, weight: .bold))
                    .opacity(1 - topBarAlpha)

                infoGrid

                storySection

                imdbSection

                divider

                directorSection

                starsSection

                reviewsSection

                writeReviewButton
                
                .padding(.top, 18)

                Spacer().frame(height: 30)
            }
            
            .padding(.horizontal, 20)
            .padding(.top, -30)
        }
        .ignoresSafeArea()
        //to measure scroll offset correctly
        .coordinateSpace(name: "scroll")
        //Receive the offset updates from the PreferenceKey
        .onPreferenceChange(ScrollOffsetKey.self) { scrollY = $0 }

        .overlay(alignment: .top) { topBar }
        .background(Color(.systemBackground).ignoresSafeArea())
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
    }

    //Sticky bar transition progress
    private var topBarAlpha: CGFloat {
        let offset = -scrollY
        let start: CGFloat = 110
        let end: CGFloat = 220
        return min(max((offset - start) / (end - start), 0), 1)
    }


    private var header: some View {
        let offset = -scrollY
        let collapse = min(max(offset, 0), headerMax - headerMin)
        let height = headerMax - collapse

        return ZStack(alignment: .top) {
            // Image(movie.backdropName)
            Image("Image")
                .resizable()
                .scaledToFill()
                .frame(height: height)
            
                .clipped()

            LinearGradient(
                colors: [
                    Color(.systemBackground).opacity(0.0),
                    Color(.systemBackground).opacity(0.050),
                    Color(.systemBackground).opacity(1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height)
        }
        .frame(height: height)
        .ignoresSafeArea(edges: .top)
    }
    
    private var topBar: some View {
        let barFill = Color(red: 18/255, green: 18/255, blue: 18/255)

        let barBorder = Color(red: 52/255, green: 52/255, blue: 52/255)

        return VStack(spacing: 0) {
            HStack {

                circleIcon(system: "chevron.left") { }

                Spacer()

                Text(movie.title)
                    .font(.system(size: 18, weight: .semibold))
                    .opacity(topBarAlpha)

                Spacer()

                circleIcon(system: "square.and.arrow.up") { }
                circleIcon(system: "bookmark") { }
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            .padding(.bottom, 10)
            .background(
                ZStack {
                    Rectangle()
                        .fill(barFill.opacity(topBarAlpha))

                    Rectangle()
                        .stroke(barBorder.opacity(topBarAlpha), lineWidth: 0.3)
                }
            )
        }
        .ignoresSafeArea(edges: .top)
    }

    private func circleIcon(system: String, action: @escaping () -> Void) -> some View {
        let circleFill = Color(red: 127.5/255, green: 127.5/255, blue: 127.5/255).opacity(0.15)

        let iconColor = Color(red: 243/255, green: 204/255, blue: 79/255)

        return Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(circleFill)
                .clipShape(Circle())
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }

    // MARK: - Info Grid
    private var infoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .leading)
        ], spacing: 18) {
            infoItem(title: "Duration", value: movie.duration)
            infoItem(title: "Language", value: movie.language)
            infoItem(title: "Genre", value: movie.genre)
            infoItem(title: "Age", value: movie.ageRating)
        }
        .padding(.top, 8)
    }

    private func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))

            Text(value)
                .font(.system(size: 13))
                .foregroundStyle(.opacity(0.6))
        }
    }

    private var storySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Story")
                .font(.system(size: 18, weight: .bold))

            Text(movie.story)
                .font(.system(size: 14))
                .foregroundStyle(.opacity(0.55))
                .lineSpacing(4)
        }
        .padding(.top, 6)
    }

    private var imdbSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("IMDb Rating")
                .font(.system(size: 18, weight: .bold))

            Text(movie.imdbRating)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.opacity(0.7))
        }
        .padding(.top, 6)
    }

    private var divider: some View {
        Rectangle()
            .fill(.opacity(0.15))
            .frame(height: 1)
            .padding(.vertical, 14)
    }

    private var directorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Director")
                .font(.system(size: 18, weight: .bold))
               

            VStack(spacing: 12) {
                //Image(movie.directorImageName)
                Image("Image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 76, height: 76)
                    .clipShape(Circle())

                Text(movie.directorName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.opacity(0.75))

                Spacer()
            }
        }
    }

    private var starsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stars")
                .font(.system(size: 18, weight: .bold))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(movie.stars) { star in
                        VStack(spacing: 8) {
                            //Image(star.imageName)
                            Image("Image")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 76, height: 76)
                                .clipShape(Circle())

                            Text(star.name)
                                .font(.system(size: 12, weight: .semibold))
                                .lineLimit(1)
                                .frame(width: 100)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.top, 6)
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Rating & Reviews")
                .font(.system(size: 18, weight: .bold))

            Text(movie.averageAppRating)
                .font(.system(size: 44, weight: .bold))

            Text("out of 5")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.opacity(0.7))
                .padding(.top, -15)
                .padding(.bottom, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(movie.reviews) { review in
                        reviewCard(review)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.top, 8)
    }

    private func reviewCard(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                //Image(review.userAvatarName)
                Image("Image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 120)
                        .foregroundStyle(.opacity(0.85))

                    starsRow(count: review.stars)
                }

                Spacer()

                
            }

            Text(review.text)
                .font(.system(size: 13))
                .lineSpacing(3)
                .lineLimit(5)
            
            Text(review.dateText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.opacity(0.45))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .frame(width: 280, alignment: .leading)
        .background(.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func starsRow(count: Int) -> some View {
        HStack(spacing: 1) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: i < count ? "star.fill" : "star")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.iconColor.opacity(i < count ? 0.9 : 0.25))
            }
        }
        .padding(.leading,8)
    }

    private var writeReviewButton: some View {
        Button(action: { }) {
            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16, weight: .semibold))

                Text("Write a review")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.35))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color(red: 127.5/255, green: 127.5/255, blue: 127.5/255).opacity(0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(red: 0.95, green: 0.82, blue: 0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private struct ScrollOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

//sample data ((change later))
#Preview {
    NavigationStack {
        MovieDetails(movie: Movie(
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
                    dateText: "september 13,2021"
                ),
                Review(
                    userName: "Afnan Abdullah",
                    userAvatarName: "user1",
                    stars: 4,
                    text: "This is an engagingly simple, good-hearted film, with just enough darkness around the edges",
                    dateText: "september 13,2021"
                ),
                Review(
                    userName: "Afnan Abdullah",
                    userAvatarName: "user1",
                    stars: 4,
                    text: "This is an engagingly simple, good-hearted film, with just enough darkness around the edges",
                    dateText: "september 13,2021"
                )
            ],
            averageAppRating: "4.8"
        ))
    }
}
