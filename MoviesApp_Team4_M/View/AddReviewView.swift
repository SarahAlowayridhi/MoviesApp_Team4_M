//
//  AddReviewView.swift
//  MoviesApp_Team4_M
//
//  Created by Ruba Alghamdi on 05/07/1447 AH.
//

import SwiftUI


struct AddReviewView: View {

    let movie_id: String
    let onPosted: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var review_text = ""
    @State private var rate = 0

    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var didPost = false

    var body: some View {
        VStack(spacing: 24) {

            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                    .foregroundColor(.yellow)
                }

                Spacer()

                Text("Write a review")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Button { Task { await submit() } } label: {
                    if isSubmitting {
                        ProgressView().tint(.yellow)
                    } else {
                        Text("Add")
                            .foregroundColor(canSubmit ? .yellow : .gray)
                    }
                }
                .disabled(!canSubmit || isSubmitting)
            }
            .padding(.horizontal)

            Divider()

            Text("Review")
                .font(.headline)
                .fontWeight(.medium)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $review_text)
                .frame(height: 146)
                .padding(1)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding(.horizontal)
                .overlay {
                    if review_text.trimmed.isEmpty {
                        Text("Add a review")
                            .foregroundColor(.white.opacity(0.35))
                            .padding(.horizontal, 26)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                }

            HStack {
                Text("Rating")
                    .font(.headline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)

                starsPicker
            }
            .padding(.horizontal)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .padding(.horizontal)
            }

            if didPost {
                Text("Review added")
                    .foregroundStyle(.green)
                    .font(.footnote)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var starsPicker: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rate ? "star.fill" : "star")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.yellow)
                    .onTapGesture { rate = i }
                    .accessibilityLabel("\(i) stars")
            }
        }
    }

    private var canSubmit: Bool {
        rate > 0 && !review_text.trimmed.isEmpty
    }

    private func submit() async {
        guard canSubmit else { return }

        isSubmitting = true
        errorMessage = nil
        didPost = false
        defer { isSubmitting = false }

        do {
            let payload = Airtable.ReviewCreateFields(
                rate: Double(rate),
                review_text: review_text.trimmed,
                movie_id: movie_id,
                user_id: nil
            )

            try await Airtable.createReview(fields: payload)

            didPost = true
            onPosted?()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


#Preview {
    NavigationStack {
        AddReviewView(
            movie_id: "recDqCgEPTo0zJKl8",
            onPosted: { /* no-op in preview */ }
        )
    }
}
