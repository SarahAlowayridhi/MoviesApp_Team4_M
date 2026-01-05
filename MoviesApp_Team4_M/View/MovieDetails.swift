//
//  MovieDetails.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 13/07/1447 AH.
//

import SwiftUI
import UIKit

// MARK: - Shared

extension Color {
    static let iconColor = Color(red: 243/255, green: 204/255, blue: 79/255)
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

// MARK: - View

struct MovieDetails: View {
    let recordId: String

    @StateObject private var vm = MovieDetailsVM()
    @State private var scrollY: CGFloat = 0

    private let headerMax: CGFloat = 420
    private let headerMin: CGFloat = 120

    private let infoColumns: [GridItem] = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading)
    ]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {

            GeometryReader { geo in
                Color.clear.preference(
                    key: ScrollOffsetKey.self,
                    value: geo.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)

            header

            VStack(alignment: .leading, spacing: 18) {

                statusArea

                Text(vm.titleText)
                    .font(.system(size: 32, weight: .bold))
                    .opacity(1 - topBarAlpha)

                // merged: info + story + imdb (+ divider)
                detailsBlock

                // merged: director + stars
                peopleBlock

                // reviews stays as one block
                reviewsSection

                writeReviewButton
                    .padding(.top, 18)

                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, -30)
        }
        .ignoresSafeArea()
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetKey.self) { scrollY = $0 }
        .overlay(alignment: .top) { topBar }
        .background(Color(.systemBackground).ignoresSafeArea())
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)

        // ⭐️ sara change:
        // نخلي تحميل الداتا (الفيلم/الممثلين/المخرج/الريفيو) هنا فقط مرة وحدة
        .task(id: recordId) { await vm.load(recordId: recordId) }

        .sheet(isPresented: $vm.isShareSheetPresented) {
            ShareSheet(items: vm.shareItems)
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Derived

    private var topBarAlpha: CGFloat {
        let offset = -scrollY
        let start: CGFloat = 110
        let end: CGFloat = 220
        return min(max((offset - start) / (end - start), 0), 1)
    }

    // MARK: - Header + TopBar

    private var header: some View {
        let offset = -scrollY
        let collapse = min(max(offset, 0), headerMax - headerMin)
        let height = headerMax - collapse

        return ZStack(alignment: .top) {
            Image("Image")
                .resizable()
                .scaledToFill()
                .frame(height: height)
                .clipped()

            LinearGradient(
                colors: [
                    Color(.systemBackground).opacity(0.0),
                    Color(.systemBackground).opacity(0.05),
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
                circleIcon(system: "chevron.left") { dismiss() }

                Spacer()

                Text(vm.titleText)
                    .font(.system(size: 18, weight: .semibold))
                    .opacity(topBarAlpha)

                Spacer()

                circleIcon(system: "square.and.arrow.up") {
                    vm.prepareShare(recordId: recordId)
                }

                circleIcon(system: vm.isSaved ? "bookmark.fill" : "bookmark") {
                    // ⭐️ sara change: توحيد مفتاح userId (بدال user_id)
                    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
                    guard !userId.isEmpty else {
                        vm.errorMessage = "No user is signed in."
                        return
                    }
                    Task {
                        await vm.saveMovieToSaved(userId: userId, movieRecordId: recordId)
                    }
                }
                .opacity(vm.isSaving ? 0.6 : 1)
                .disabled(vm.isSaving)

                // ⭐️ sara change:
                // هذي .task فقط لتحميل حالة الحفظ المحلية (بدون إعادة vm.load)
                .task(id: recordId) {
                    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
                    if !userId.isEmpty {
                        vm.loadSavedLocalState(userId: userId, movieRecordId: recordId)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            .padding(.bottom, 10)
            .background(
                ZStack {
                    Rectangle().fill(barFill.opacity(topBarAlpha))
                    Rectangle().stroke(barBorder.opacity(topBarAlpha), lineWidth: 0.3)
                }
            )
        }
        .ignoresSafeArea(edges: .top)
    }

    private func circleIcon(system: String, action: @escaping () -> Void) -> some View {
        let circleFill = Color.gray.opacity(0.15)

        return Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.iconColor)
                .frame(width: 32, height: 32)
                .background(circleFill)
                .clipShape(Circle())
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }

    // MARK: - Merged Blocks

    private var statusArea: some View {
        Group {
            if vm.isLoading {
                ProgressView()
                    .padding(.top, 20)
            }

            if let errorMessage = vm.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
    }

    /// Info grid + Story + IMDb + divider (all in one “Details” block)
    private var detailsBlock: some View {
        VStack(alignment: .leading, spacing: 18) {

            LazyVGrid(columns: infoColumns, spacing: 18) {
                infoItem(title: "Duration", value: vm.runtimeText)
                infoItem(title: "Language", value: vm.languageText)
                infoItem(title: "Genre", value: vm.genreText)
            }
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 10) {
                Text("Story")
                    .font(.system(size: 18, weight: .bold))

                Text(vm.storyText)
                    .font(.system(size: 14))
                    .foregroundStyle(.opacity(0.55))
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("IMDb Rating")
                    .font(.system(size: 18, weight: .bold))

                Text(vm.imdbText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.opacity(0.7))
            }

            Rectangle()
                .fill(.opacity(0.15))
                .frame(height: 1)
                .padding(.top, 6)
        }
    }

    /// Director + Stars (one “People” block)
    private var peopleBlock: some View {
        VStack(alignment: .leading, spacing: 18) {

            VStack(alignment: .leading, spacing: 12) {
                Text("Director")
                    .font(.system(size: 18, weight: .bold))

                VStack(spacing: 12) {
                    directorImage

                    Text(vm.directorNameText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.opacity(0.75))
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Stars")
                    .font(.system(size: 18, weight: .bold))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(Array(vm.actors.enumerated()), id: \.offset) { _, actor in
                            VStack(spacing: 8) {
                                actorImage(actor)

                                Text(actor.name ?? "-")
                                    .font(.system(size: 12, weight: .semibold))
                                    .lineLimit(1)
                                    .frame(width: 100)
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(.top, 6)
    }

    // MARK: - Reviews

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Rating & Reviews")
                .font(.system(size: 18, weight: .bold))

            Text(vm.averageAppRatingText)
                .font(.system(size: 44, weight: .bold))

            Text("out of 5")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.opacity(0.7))
                .padding(.top, -15)
                .padding(.bottom, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(vm.reviewsUI) { review in
                        reviewCard(review)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Small Helpers

    private func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))

            Text(value)
                .font(.system(size: 13))
                .foregroundStyle(.opacity(0.6))
        }
    }

    private var directorImage: some View {
        Group {
            if let url = vm.directorImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Image("Image").resizable().scaledToFill()
                    }
                }
            } else {
                Image("Image").resizable().scaledToFill()
            }
        }
        .frame(width: 76, height: 76)
        .clipShape(Circle())
    }

    private func actorImage(_ actor: Actors) -> some View {
        Group {
            if let url = vm.actorImageURL(actor) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Image("Image").resizable().scaledToFill()
                    }
                }
            } else {
                Image("Image").resizable().scaledToFill()
            }
        }
        .frame(width: 76, height: 76)
        .clipShape(Circle())
    }

    private func reviewCard(_ review: ReviewUI) -> some View {
        // ⭐️ sara change: جلب userId الحالي (المستخدم المسجّل)
        let currentUserId = UserDefaults.standard.string(forKey: "userId") ?? ""

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
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

                // ⭐️ sara change:
                // زر حذف الريفيو يظهر فقط إذا الريفيو للمستخدم الحالي (صاحب الريفيو)
                if review.userId == currentUserId {
                    Button {
                        Task { await vm.deleteReview(reviewId: review.id) }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
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
        .padding(.leading, 8)
    }

    private var writeReviewButton: some View {
        NavigationLink {
            AddReviewView(movie_id: recordId) {
                Task { await vm.load(recordId: recordId) }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16, weight: .semibold))

                Text("Write a review")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(Color(red: 0.95, green: 0.82, blue: 0.35))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color.gray.opacity(0.15))
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

// MARK: - Review UI Model

struct ReviewUI: Identifiable {
    let id: String

    // ⭐️ sara change: لازم userId عشان نعرف صاحب الريفيو ونخليه يحذف ريفيوه فقط
    let userId: String?

    let userName: String
    let stars: Int
    let text: String
    let dateText: String
}

#Preview {
    NavigationStack {
        MovieDetails(recordId: "recDqCgEPTo0zJKl8")
    }
}

