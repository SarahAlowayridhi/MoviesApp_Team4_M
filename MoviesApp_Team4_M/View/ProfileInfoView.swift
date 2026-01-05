import SwiftUI

struct ProfileInfoView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    @State private var goToEdit = false
    @StateObject private var viewModel = ProfileViewModel()

    @AppStorage("isLoggedIn") private var isLoggedIn = true

    let user: UserRecord?

    var body: some View {

        VStack(spacing: 24) {

            // MARK: - Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                    .foregroundColor(.yellow)
                }

                Spacer()

                Text("Profile info")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    goToEdit = true
                } label: {
                    Text("Edit")
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal)

            Divider()

            // MARK: - Profile image
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 110, height: 110)

                ProfileImageView(
                    imageUrl: user?.fields.profile_image,
                    size: 65
                )
            }
            .padding(.top, 8)

            // MARK: - Info card
            VStack(spacing: 0) {

                HStack {
                    Text("Name")
                        .foregroundColor(.white)

                    Spacer()

                    Text(user?.fields.name ?? "—")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()

                Divider()

                HStack {
                    Text("Email")
                        .foregroundColor(.white)

                    Spacer()

                    Text(user?.fields.email ?? "—")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .background(Color.gray.opacity(0.35))
            .cornerRadius(16)
            .padding(.horizontal)

            Spacer()

            Button {
                UserDefaults.standard.removeObject(forKey: "userId")
                isLoggedIn = false
            } label: {
                Text("Sign Out")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.35))
                    .cornerRadius(16)
            }


            .padding(.horizontal)
            .padding(.bottom)

            .navigationDestination(isPresented: $goToEdit) {
                ProfileEditView(user: user)
            }
        }
        .padding(.top, 8)
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ProfileInfoView(user: nil)
    }
}

