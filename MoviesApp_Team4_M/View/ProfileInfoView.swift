import SwiftUI

struct ProfileInfoView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var goToEdit = false

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
                    goToEdit = true
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

                    Text("\tSarah")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()

                Divider()

                HStack {
                    Text("Last name")
                        .foregroundColor(.white)

                    Spacer()

                    Text("\tAbdullah")
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
            
            .navigationDestination(isPresented: $goToEdit) {
                ProfileEditView()
            }
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

