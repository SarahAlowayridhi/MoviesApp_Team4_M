import SwiftUI

struct ProfileInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {

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
                    // later: edit action
                } label: {
                    Text("Edit")
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal)

            Divider()

            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 110, height: 110)

                Image("profilephoto")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
            .padding(.top, 8)

            VStack(spacing: 0) {

                HStack {
                    Text("First name")
                        .foregroundColor(.white)

                    Spacer()

                    Text("Sarah")
                        .foregroundColor(.white)
                }
                .padding()

                Divider()

                HStack {
                    Text("Last name")
                        .foregroundColor(.white)

                    Spacer()

                    Text("Abdullah")
                        .foregroundColor(.white)
                }
                .padding()
            }
            .background(Color.gray.opacity(0.35))
            .cornerRadius(16)
            .padding(.horizontal)

            Spacer()

            Button {
                // For now: just pop back to ProfileView
                // (If you want REAL sign out -> SignInView, tell me and I’ll wire it via RootView binding)
                dismiss()
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
        }
        .padding(.top, 8)
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ProfileInfoView()
    }
}
