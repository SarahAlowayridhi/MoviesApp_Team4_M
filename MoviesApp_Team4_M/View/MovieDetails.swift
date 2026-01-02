//
//  MovieDetails.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 13/07/1447 AH.
//

import SwiftUI

extension Color {
    static let iconColor = Color(red: 243/255, green: 204/255, blue: 79/255)
}

struct MovieDetails: View {
    let recordId: String

    @StateObject private var vm = MovieDetailsVM()
    @State private var scrollY: CGFloat = 0

    private let headerMax: CGFloat = 420
    private let headerMin: CGFloat = 120

    // Grid columns are constant; no need to recreate them every render
    private let infoColumns: [GridItem] = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .leading)
    ]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {

            // Hard part: this reads the ScrollView offset and pushes it into `scrollY`
            GeometryReader { geo in
                Color.clear.preference(
                    key: ScrollOffsetKey.self,
                    value: geo.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)

            header

            VStack(alignment: .leading, spacing: 18) {

                if vm.isLoading {
                    ProgressView().padding(.top, 20)
                }

                if let errorMessage = vm.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Text(vm.titleText)
                    .font(.system(size: 32, weight: .bold))
                    .opacity(1 - topBarAlpha)

                infoGrid
                storySection
                imdbSection
                divider

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
        .task(id: recordId) { await vm.load(recordId: recordId) }
    }

    // MARK: - UI-only logic
    private var topBarAlpha: CGFloat {
        // Hard part: fade in title while scrolling (clamped 0...1)
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
                circleIcon(system: "chevron.left") { dismiss() }

                Spacer()

                Text(vm.titleText)
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
                    Rectangle().fill(barFill.opacity(topBarAlpha))
                    Rectangle().stroke(barBorder.opacity(topBarAlpha), lineWidth: 0.3)
                }
            )
        }
        .ignoresSafeArea(edges: .top)
    }

    private func circleIcon(system: String, action: @escaping () -> Void) -> some View {
        let circleFill = Color(red: 127.5/255, green: 127.5/255, blue: 127.5/255).opacity(0.15)

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

    // MARK: - Info Grid
    private var infoGrid: some View {
        LazyVGrid(columns: infoColumns, spacing: 18) {
            infoItem(title: "Duration", value: vm.runtimeText)
            infoItem(title: "Language", value: vm.languageText)
            infoItem(title: "Genre", value: vm.genreText)
        }
        .padding(.top, 8)
    }

    private func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 14, weight: .semibold))
            Text(value)
                .font(.system(size: 13))
                .foregroundStyle(.opacity(0.6))
        }
    }

    private var storySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Story").font(.system(size: 18, weight: .bold))
            Text(vm.storyText)
                .font(.system(size: 14))
                .foregroundStyle(.opacity(0.55))
                .lineSpacing(4)
        }
        .padding(.top, 6)
    }

    private var imdbSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("IMDb Rating").font(.system(size: 18, weight: .bold))
            Text(vm.imdbText)
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

    private struct ScrollOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetails(recordId: "recDqCgEPTo0zJKl8")
    }
}
