import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Back should dismiss (go back to MoviesCenter)
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.yellow)

                    Text("Back")
                        .font(.title3)
                        .foregroundColor(.yellow)
                }
            }

            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)

            // This whole card should navigate to ProfileInfo
            NavigationLink {
                ProfileInfoView()
            } label: {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.35))
                        .frame(height: 110)
                        .cornerRadius(16)

                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 80)

                            Image("profilephoto")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Sarah Abdullah")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Xxxx234@gmail.com")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }
            }
            .buttonStyle(.plain)

            Text("Saved movies")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)

            Spacer()

            VStack(spacing: 12) {
                Image("movieisme logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 73.07, height: 43.66)
                    .foregroundColor(.gray.opacity(0.6))

                Text("No saved movies yet, start save\nyour favourites")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
